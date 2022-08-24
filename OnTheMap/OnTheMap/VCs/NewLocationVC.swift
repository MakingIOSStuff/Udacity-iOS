//
//  NewLocationVC.swift
//  OnTheMap
//
//  Created by Joel Gans on 8/22/22.
//

import Foundation
import UIKit
import MapKit

class NewLocationVC:  UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var newLocationTextField: UITextField!
    @IBOutlet weak var urlTextField: UITextField!
    
    var userUrlLink: String = ""
    var pinCoords = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    
    //MARK: Process finding new location and pass to next VC
    func newUserLocation(_ location: String) {
        CLGeocoder().geocodeAddressString(location) { (newPlace, error) in
            guard let newPlace = newPlace
            else {
                self.showError(message: error!.localizedDescription)
                return
            }
            let coordinates = newPlace.first!.location!.coordinate
            self.pinCoords = coordinates
            self.performSegue(withIdentifier: "confirmLocationVC", sender: (location, coordinates))
        }
    }
    
    //MARK: Find location button press
    @IBAction func findLocationButton(_ sender: Any) {
        userUrlLink = urlTextField.text ?? ""
        guard let location = newLocationTextField.text else { return }
        newUserLocation(location)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "confirmLocationVC" {
            if let destinationViewController = (segue.destination as? ConfirmLocationVC) {
                destinationViewController.location = newLocationTextField.text ?? ""
                destinationViewController.xyCoords = pinCoords
                destinationViewController.userLink = userUrlLink
            }
        }
    }
    
    //MARK: Display error
    func showError(message: String) {
        let alertVC = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        show(alertVC, sender: nil)
    }
}
