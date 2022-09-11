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
    
    
    //MARK: Core data setup
    var photo: Photo!
    var pin: Pin!
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    
    let backgroundImageDownloadQueue = DispatchQueue(label: "com.vt.image_download_queue")
    
    
    func setupFetchedResultsController() {
        debugPrint("setup before fetch")
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pin)
        let sortDescriptor = NSSortDescriptor(key: "picture", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.predicate = predicate
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            debugPrint("doing the fetch")
            try fetchedResultsController.performFetch()
        } catch {
            print("Could not perform fetch: \(error.localizedDescription)")
            return
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFetchedResultsController()
        placeMapPin(latitude: pin.latitude, longitude: pin.longitude)
        setCellSize()
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
    func setCellSize() {
        let spacing: CGFloat = 3
        let width = UIScreen.main.bounds.width
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: 50, right: spacing)
        let numberOfItems: CGFloat = 3
        let itemSize = (width - (spacing * (numberOfItems+1))) / numberOfItems
        layout.itemSize = CGSize(width: itemSize, height: itemSize)
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = spacing
        collectionView.collectionViewLayout = layout
    }
    
    private func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotationView) -> MKAnnotationView? {
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: "ImageCells") as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation as? MKAnnotation, reuseIdentifier: "ImageCells")
            pinView?.canShowCallout = true
            pinView?.tintColor = .red
            pinView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            pinView?.animatesDrop = true
        } else {
            pinView?.annotation = annotation as? MKAnnotation
        }
        return pinView
    }
    
    @IBAction func newCollectionButtonPressed(_ sender: Any) {
        newCollectionButton.isEnabled = false
        guard photo.picture?.isEmpty != true else { return }
        dataController.viewContext.delete(photo)
        downLoadImagesForPin()
        saveContext()
        
        collectionView.reloadData()
        newCollectionButton.isEnabled = true
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
                let urlsToStore = downloadedImageUrls.map { FlickrPhoto -> Photo in
                    let images = Photo(context: self.dataController.viewContext)
                    images.url = FlickrClient.Endpoints.photoURL(FlickrPhoto.server, FlickrPhoto.id, FlickrPhoto.secret).url
                    if let url = images.url {
                        self.downloadImage(imagePath: url.absoluteString) { imageData, error in
                            return
                        }
                    }
                    return images
                }
                self.pin.addToPics(NSOrderedSet(array: urlsToStore))
                try? self.dataController.viewContext.save()
                self.setupFetchedResultsController()
                self.newCollectionButton.isEnabled = true
            } else {
                print("Failed to get new photo collection. Error: \(String(describing: error?.localizedDescription))")
            }
            
        }
    }
}














