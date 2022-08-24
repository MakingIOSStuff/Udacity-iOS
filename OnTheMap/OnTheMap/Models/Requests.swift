//
//  Requests.swift
//  OnTheMap
//
//  Created by Joel Gans on 8/22/22.
//

import Foundation

//This file contains request code.

//MARK: UserCredentials
struct userCredentials: Codable {
    let email: String
    let password: String
}

//MARK: LoginRequest
struct loginRequest: Codable {
    let loginApi: userCredentials
    init(email: String, password: String) {
        loginApi = userCredentials(email: email, password: password)
    }
}

//MARK: SessionRequests
struct User: Codable {
    let username: String
    let password: String
}

struct sessionRequest: Codable {
    let user: User
    
    enum CodingKeys: String, CodingKey {
        case user = "udacity"
    }
}
