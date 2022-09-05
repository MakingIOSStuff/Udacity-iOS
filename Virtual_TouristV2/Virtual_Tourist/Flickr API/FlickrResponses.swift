//
//  FlickrResponses.swift
//  Virtual_Tourist
//
//  Created by Joel Gans on 8/28/22.
//

import Foundation

struct FlickrResponse: Codable {
    let photos: FlickrPhotos
}
struct FlickrPhotos: Codable {
    let page: Int
    let pages: Int
    let perpage: Int
    let total: Int
    let photo: [FlickrPhoto]
}
struct FlickrPhoto: Codable{
    let id: String
    let server: String
    let secret: String
}
