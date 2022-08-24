//
//  StudentLocationData.swift
//  OnTheMap
//
//  Created by Joel Gans on 8/22/22.
//

import Foundation
import MapKit

// This file will contain the various student location data. User MARK to find specific values.



//MARK: StudentLocationMapPin
struct studentLocation: Codable {
    let createdAt: String?
    let updatedAt: String?
    let firstName: String?
    let lastName: String?
    let latitude: Double?
    let longitude: Double?
    let mapString: String?
    let mediaURL: String?
    let objectID: String?
    let uniqueKey: String?
    
    var studentPin: MKPointAnnotation {
        let mapAnnotation = MKPointAnnotation()
        mapAnnotation.coordinate = CLLocationCoordinate2DMake(CLLocationDegrees(latitude ?? 0.0), CLLocationDegrees(longitude ?? 0.0))
        mapAnnotation.title = "\(firstName ?? "") \(lastName ?? "")"
        mapAnnotation.subtitle = "\(mediaURL ?? "")"
        return mapAnnotation
    }
    
}
