//
//  MapVC.swift
//  OnTheMap
//
//  Created by Joel Gans on 8/22/22.
//

import UIKit
import MapKit

class MapVC: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        getLocationPins()
    }
    
    //MARK: Map View Setup
    func mapView(_ mapView: MKMapView, viewFor views: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "mapPin"
        var mapPin = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if mapPin == nil {
            mapPin = MKPinAnnotationView(annotation: views, reuseIdentifier: reuseId)
            mapPin!.canShowCallout = true
            mapPin!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure) as UIButton
            mapPin!.pinTintColor = .red
        } else {
            mapPin!.annotation = views
        }
        return mapPin
    }
    
    //MARK: Map Informational Link Function
    func mapView(_ mapView: MKMapView, annotationView views: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let mediaURL = URL(string: views.annotation!.subtitle!!) {
            UIApplication.shared.open(mediaURL,options: [:], completionHandler: nil)
        }
    }
    
    
    func getLocationPins() {
        UdacityClient.getAllStudentLocationsWithLimit(limit: 100, completion: { (results, error) in
            if let results = results {
                 StudentArray.students = results
                self.mapView.addAnnotations(self.getAnnotations())
                } else {
                self.showError(message: error!.localizedDescription)
            }
        })
    }
    
    func getAnnotations() -> [MKPointAnnotation] {
        var locationPins = [MKPointAnnotation]()
        for studentLocation in StudentArray.students {
            locationPins.append(studentLocation.studentPin)
        }
        return locationPins
    }
    
    //MARK: Display error
    func showError(message: String) {
        let alertVC = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        show(alertVC, sender: nil)
    }
    
    //MARK: Logout Button Functionality
    @IBAction func logoutButtonPush(_ sender: Any) {
        UdacityClient.logout { ( success, error) in
            if success {
                self.presentingViewController?.dismiss(animated: true, completion:  nil)
            } else {
                self.showError(message: error!.localizedDescription)
            }
        }
    }
}
