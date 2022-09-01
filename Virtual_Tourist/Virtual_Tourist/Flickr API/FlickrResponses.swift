//
//  FlickrResponses.swift
//  Virtual_Tourist
//
//  Created by Joel Gans on 8/28/22.
//

import Foundation

struct FlickrResponse: Codable, Equatable {
    let photos: FlickrPhotos
    let stat: String
}

struct FlickrPhotos: Codable, Equatable {
    let page: Int
    let pages: Int
    let perPage: Int
    let photo: [FlickrPhoto]
    let total: Int
    
    enum CodingKeys: String, CodingKey {
        case page
        case pages
        case perPage = "perpage"
        case photo
        case total
    }
}

struct FlickrPhoto: Codable, Equatable {
    let isFamily: Int
    let isFriend: Int
    let isPublic: Int
    let farm: Int
    let id: String
    let owner: String
    let secret: String
    let server: String
    let title: String
    let url_n: String
    
    enum CodingKeys: String, CodingKey {
        case isFamily = "isfamily"
        case isFriend = "isfriend"
        case isPublic = "ispublic"
        case farm
        case id
        case owner
        case secret
        case server
        case title
        case url_n
    }
}
