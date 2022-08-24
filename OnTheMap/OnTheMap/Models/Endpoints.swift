//
//  Endpoints.swift
//  OnTheMap
//
//  Created by Joel Gans on 8/22/22.
//

import Foundation

// MARK: Endpoints for API calls
class EndPoints {
    
    enum EndPoint{
        static let base = "https://onthemap-api.udacity.com/v1"
        
        case createSessionId
        case getUserInfo(userId: String)
        case postUserInfo
        case studentLocation
        case studentLocationLimit(limit: Int)
        case logout
        
        var stringvalue: String {
            switch self {
            case .createSessionId:
                return EndPoint.base + "/session"
            case .logout:
                return EndPoint.base + "/session"
            case .getUserInfo(let userId):
                return "\(EndPoint.base)/user/\(userId)"
            case .postUserInfo:
                return "\(EndPoint.base)/StudentLocation"
            case .studentLocation:
                return EndPoint.base + "/StudentLocation?order=-updatedAt"
            case .studentLocationLimit(let limit):
                return "\(EndPoint.base)/StudentLocation?Limit=\(String(limit))&order=-updatedAt"
            }
        }
        // MARK: URL var
        var url: URL{
            return URL(string: stringvalue)!
        }
    }
}
