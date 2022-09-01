//
//  PhotoGalleryViewController.swift
//  Virtual_Tourist
//
//  Created by Joel Gans on 8/28/22.
//

import Foundation
import UIKit
import MapKit
import CoreData

class PhotoGalleryViewController: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate {
    
    //MARK: Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    var storedPhotos: Bool!
    
    //MARK: Core data setup
    var pin: Pin!
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Pin>!
    
    let backgroundImageDownloadQueue = DispatchQueue(label: "com.vt.image_download_queue")
    
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "latitude", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "pins")
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Could not perform fetch: \(error.localizedDescription)")
            return
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        placeMapPin(latitude: pin.latitude, longitude: pin.longitude)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
    private func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotationView) -> MKAnnotationView? {
        let reuseId = "photoCells"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation as? MKAnnotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = true
            pinView?.tintColor = .red
            pinView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            pinView?.animatesDrop = true
        } else {
            pinView?.annotation = annotation as? MKAnnotation
        }
        return pinView
    }
    
    func placeMapPin(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        
        mapView.removeAnnotations(mapView.annotations)
        //Get the coords for new pin
        let annotation = MKPointAnnotation()
        annotation.coordinate.latitude = latitude
        annotation.coordinate.longitude = longitude
        //Set the new map pin view
        self.mapView.addAnnotation(annotation)
        self.mapView.setCenter(annotation.coordinate, animated: true)
        let region = MKCoordinateRegion(center: annotation.coordinate, span: MKCoordinateSpan (latitudeDelta: 0.05, longitudeDelta: 0.05))
        self.mapView.setRegion(region, animated: true)
    }
    
    func downLoadImagesForPin() {
        FlickrClient.requestPhotos(latitude: pin.latitude, longitude: pin.longitude) { response, error in
            if let response = response {
                let downloadedImageUrls = response.photos.photo
                _ = downloadedImageUrls.map { FlickrPhoto -> ImageURL in
                    let images = ImageURL(context: self.dataController.viewContext)
                    images.url = FlickrClient.Endpoints.photoURL(FlickrPhoto.server, FlickrPhoto.id, FlickrPhoto.secret).url
                    return images
                }
            }
        }
    }
}













