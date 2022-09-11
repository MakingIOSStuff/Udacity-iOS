//
//  MapViewController.swift
//  Virtual_Tourist
//
//  Created by Joel Gans on 8/28/22.
//

import Foundation
import UIKit
import CoreData
import MapKit

class MapViewController: UIViewController, NSFetchedResultsControllerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    
    //MARK: CoreData Properties
    var pin: Pin!
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Pin>!
    
    func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "latitude", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        print("Fetched: \(fetchRequest)")
        do {
            try fetchedResultsController.performFetch()
            print("Successful fetch of \(String(describing: fetchedResultsController.fetchedObjects))")
        } catch {
            print("Could not perform fetch: \(error.localizedDescription)")
            return
        }
    }
    
    override func viewDidLoad() {
        super .viewDidLoad()
        mapView.delegate = self
        
        let holdtoPlace = UILongPressGestureRecognizer(target: self, action: #selector(placeNewPin(_:)))
        mapView.addGestureRecognizer(holdtoPlace)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupFetchedResultsController()
        loadPins()
        print("Try to fetch")
        let fetchattempt = fetchedResultsController.fetchedObjects
        print("The fetch returned: \(String(describing: fetchattempt))")
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
        mapView.removeAnnotations(mapView.annotations)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let pinView = mapView.dequeueReusableAnnotationView(withIdentifier: "pins") as? MKPinAnnotationView {
            pinView.annotation = annotation
            return pinView
        } else {
            let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pins")
            pinView.canShowCallout = true
            pinView.pinTintColor = .red
            pinView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            pinView.animatesDrop = true
            return pinView
        }
    }
    
    func loadPins() {
        let pins = fetchedResultsController.fetchedObjects!
        print("Found \(pins.count) pins. Tossing to the map")
        var annotations = [MKPointAnnotation]()
        //Extract the pin locations
        for pin in pins {
            let latitude = CLLocationDegrees(pin.latitude)
            let longitude = CLLocationDegrees(pin.longitude)
            let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let locations = MKPointAnnotation()
            locations.coordinate = coordinates
            //Add locations to annotations array
            annotations.append(locations)
            //Pass locations of pins to map
            self.mapView.addAnnotations(annotations)
            print("Pin locations added: \(annotations)")
        }
    }
    
    @objc func placeNewPin(_ mapPress: UIGestureRecognizer) {
        if mapPress.state != .began {
            return
        } else {
            let convertToLocation = mapPress.location(in: mapView)
            let pinCoords: CLLocationCoordinate2D = mapView.convert(convertToLocation, toCoordinateFrom: self.mapView)
            
            latitude = pinCoords.latitude
            longitude = pinCoords.longitude
            //Get the coords for new pin
            let annotation = MKPointAnnotation()
            annotation.coordinate.latitude = latitude
            annotation.coordinate.longitude = longitude
            //Set the new map pin view
            self.mapView.addAnnotation(annotation)
            self.mapView.setCenter(annotation.coordinate, animated: true)
            let region = MKCoordinateRegion(center: annotation.coordinate, span: MKCoordinateSpan (latitudeDelta: 0.08, longitudeDelta: 0.08))
            self.mapView.setRegion(region, animated: true)
            debugPrint("Lets try to save the pin via .save")
            try? dataController.viewContext.save()
            //Start location photo download for new pin
            FlickrClient.requestPhotos(latitude: latitude, longitude: longitude) { response, error in
                if let response = response {
                    debugPrint("PlacePin got a photo")
                    self.savePinToStore(FlickrResponse: response.photos.photo)
                    debugPrint("\(response) was returned for the pin. Hope it saved this time")
                } else {
                    print("There was an error adding photos to library: \(error!.localizedDescription)")
                }
            }
        }
    }
    
    func savePinToStore(FlickrResponse: [FlickrPhoto]) {
        let pin = Pin(context: dataController.viewContext)
        pin.latitude = self.latitude
        pin.longitude = self.longitude
        debugPrint("time to save the new pin")
        let imageLinks = FlickrResponse.map { FlickrPhoto -> Photo in
            let imageItem = Photo(context: dataController.viewContext)
            imageItem.url = FlickrClient.Endpoints.photoURL(FlickrPhoto.server, FlickrPhoto.id, FlickrPhoto.secret).url
            debugPrint("Returning image for save")
            debugPrint("imageItem returned: \(imageItem)")
            pin.addToPics(imageItem)
            return imageItem
        }
        for response in FlickrResponse {
            debugPrint("the data in flickrResponse was: \(response)")
            let imageData = Photo(context: dataController.viewContext)
            pin.addToPics(imageData)
        }
        pin.addToPics(NSOrderedSet(array: imageLinks))
        debugPrint("adding image to array")
        self.pin = pin
        try? dataController.viewContext.save()
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        debugPrint("check fetchedResults for pin: \(String(describing: fetchedResultsController.fetchedObjects))")
        guard fetchedResultsController.fetchedObjects != nil else {
            debugPrint("Failed fetchedobject check")
            return
        }
        setupFetchedResultsController()
        for pin in fetchedResultsController.fetchedObjects! {
            if pin.latitude == view.annotation?.coordinate.latitude &&
                pin.longitude == view.annotation?.coordinate.longitude {
                debugPrint("Pin found and set: \(pin)")
                self.pin = pin
                performSegue(withIdentifier: "presentPhotoGalleryView", sender: pin)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "presentPhotoGalleryView",
              let vc = segue.destination as? PhotoGalleryViewController else {return}
        vc.pin = self.pin
        vc.dataController = self.dataController
    }
}


