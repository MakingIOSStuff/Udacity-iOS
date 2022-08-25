//
//  ConfirmLocationVC.swift
//  OnTheMap
//
//  Created by Joel Gans on 8/22/22.
//

import Foundation
import UIKit
import MapKit

class ConfirmLocationVC: UIViewController, MKMapViewDelegate{
    
    @IBOutlet weak var mapView: MKMapView!
    
    var location: String = ""
    var xyCoords: CLLocationCoordinate2D!
    var userLink: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        showUserPin(withCoordinates: xyCoords)
    }
    
    //MARK: Display the user's new pin location
    func showUserPin(withCoordinates xyCoords: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = xyCoords
        annotation.title = location
        
        //Set the map scale in animation
        let mapAnimation = MKCoordinateRegion(center: xyCoords, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        
        //Load the map
        DispatchQueue.main.async {
            self.mapView.addAnnotation(annotation)
            self.mapView.setRegion(mapAnimation, animated: true)
        }
    }
    
    //MARK: Finish button pressed
    @IBAction func finishButtonPressed(_ sender: Any) {
        UdacityClient.getUserData { (userInfo, error) in
            UdacityClient.postPin(user: PostUser(uniqueKey: UdacityClient.Auth.accountKey, userFirstName: userInfo.user.userFirstName, userLastName: userInfo.user.userLastName, mapString: self.location, mediaURL: self.userLink, latitude: self.xyCoords.latitude, longitude: self.xyCoords.longitude)) { (success, error) in
                    if success {
                        self.performSegue(withIdentifier: "backToMap", sender: nil)
                        self.dismiss(animated: true)
                    } else {
                        self.showError(message: error!.localizedDescription)
                    }
                }
            }
        }
    
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
        self.dismiss(animated: true)
    }
    
    //MARK: Display error
    func showError(message: String) {
        let alertVC = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        show(alertVC, sender: nil)
    }
}
