//
//  NewLocationVC.swift
//  OnTheMap
//
//  Created by Joel Gans on 8/22/22.
//

import UIKit
import MapKit

class NewLocationVC:  UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var newLocationTextField: UITextField!
    @IBOutlet weak var urlTextField: UITextField!
    
    var userUrlLink: String = ""
    
    
    //MARK: Process finding new location and pass to next VC
    func newUserLocation(_ location: String) {
        CLGeocoder().geocodeAddressString(location) { (newPlace, error) in
            guard let newPlace = newPlace
            else {
                self.showError(message: error!.localizedDescription)
                return
            }
            let coordinates = newPlace.first!.location!.coordinate
            self.performSegue(withIdentifier: "confirmLocationVC", sender: (location, coordinates))
        }
    }
    
    //MARK: Find location button press
    @IBAction func findLocationButton(_ sender: Any) {
        userUrlLink = urlTextField.text ?? ""
        guard let findLocation = newLocationTextField.text
        else {
            return
        }
        newUserLocation(findLocation)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "confirmLocationVC" {
            let destinationViewController = segue.destination as! ConfirmLocationVC
            let location = sender as! (String, CLLocationCoordinate2D)
            destinationViewController.location = location.0
            destinationViewController.xyCoords = location.1
            destinationViewController.userLink = userUrlLink
        }
    }
    
    //MARK: Display error
    func showError(message: String) {
        let alertVC = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        show(alertVC, sender: nil)
    }
}
