//
//  PostUser.swift
//  OnTheMap
//
//  Created by Joel Gans on 8/23/22.
//

import Foundation

//MARK: PostUser
struct PostUser: Codable {
    let uniqueKey: String
    let userFirstName: String
    let userLastName: String
    let mapString: String
    let mediaURL: String
    let latitude: Double
    let longitude: Double
}
