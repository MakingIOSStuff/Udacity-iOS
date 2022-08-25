//
//  Responses.swift
//  OnTheMap
//
//  Created by Joel Gans on 8/22/22.
//

import Foundation

//This file contains the responses that are expected.

//MARK: Response for PostUserLocation
struct postUserLocationResponse: Codable {
    let createdAt: String
    let objectId: String
}

//MARK: ErrorCodes
struct UdacityAPIErrorResponse: Codable, LocalizedError {
    let status: Int
    let error: String
    
    var errorDescription: String? {
        return error
    }
}

//MARK: UserResponse
struct userResponse: Codable {
    let user: userInfo
}

//MARK: Account Response
struct Account: Codable {
    let registered: Bool
    let key: String
}

//MARK: Session Response
struct Session: Codable {
    let id: String
    let expiration: String
}

//MARK: POSTsession response
struct postSession: Codable {
    let account: Account
    let session: Session
}
