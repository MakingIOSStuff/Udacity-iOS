//
//  Quotes.swift
//  Inspirational Bytes
//
//  Created by Joel Gans on 9/16/22.
//

import Foundation

struct QuoteResponse: Decodable, Equatable {
    let text: String
    let author: String
    let image: String?
    let count: String
    let html: String
    
    enum CodingKeys: String, CodingKey {
        case text = "q"
        case author = "a"
        case image = "i"
        case count = "c"
        case html = "h"
    }
}

struct Root: Decodable, Equatable {
    let contents: Contents
}

struct Contents: Decodable, Equatable {
    let quotes: [QuoteResponse]
}


