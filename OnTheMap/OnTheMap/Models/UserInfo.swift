//
//  UserInfo.swift
//  OnTheMap
//
//  Created by Joel Gans on 8/25/22.
//

import Foundation

//MARK: User Info Response
struct userInfo: Codable {
    let userFirstName: String
    let userLastName: String
    
    enum CodingKeys: String, CodingKey {
        case userFirstName = "first_name"
        case userLastName = "last_name"
    }
}
