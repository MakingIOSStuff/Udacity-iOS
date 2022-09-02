//
//  Flickr Client.swift
//  Virtual_Tourist
//
//  Created by Joel Gans on 8/28/22.
//

import Foundation

class FlickrClient {
    
    static let apiKey = "4ad5cebecddd8de5d20143b1846d1a03"
    static let secret = "ec31c912712d8aa1"
    
    enum Endpoints {
        static let base = "https://www.flickr.com/services/rest/?method=flickr.photos.search"
        static let photoBase = "https://live.staticflickr.com/"
        
        case requestPhotos(Double, Double)
        case photoURL(String, String, String)
        
        var stringValue: String {
            switch self {
            case .requestPhotos(let latitude, let longitude):
                return Endpoints.base + "&api_key=\(FlickrClient.apiKey)&format=json&lat=\(latitude)&lon=\(longitude)&per_page=1&page=\(Int.random(in: 1...47))&nojsoncallback=1"
            case .photoURL(let server,let id, let secret):
                return Endpoints.photoBase + "\(server)/\(id)_\(secret).jpg"
            }
        }
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    class func taskForGetRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionDataTask {
        let task = URLSession.shared.dataTask(with: url) { data, response, error  in
            guard let data = data else {
                print("the data contains \(String(describing: data))")
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            print("passed the get guard")
            print("taskGet returned: \(data) of data")
            let decoder = JSONDecoder()
            do {
                let ResponseObject = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(ResponseObject, nil)
                    print("survived the decode")
                    print("\(ResponseObject)")
                }
            } catch {
                do {
                    let errorResponse = try decoder.decode(FlickrResponse.self, from: data) as! Error
                    print("failed the decode")
                    DispatchQueue.main.async {
                        completion(nil, errorResponse)
                    }
                } catch {
                    print("somehow we errored out at error")
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
            }
        }
        task.resume()
        return task
    }
    
    class func requestPhotos(latitude: Double, longitude: Double, completion: @escaping (FlickrResponse?, Error?) -> Void) {
        taskForGetRequest(url: Endpoints.requestPhotos(latitude, longitude).url, responseType: FlickrResponse.self) { response, error in
            if let response = response {
                print("Sent Request URL: \(Endpoints.requestPhotos(latitude,longitude).url)")
                
                DispatchQueue.main.async {
                    completion(response, nil)
                }
            } else {
                completion(nil, error)
            }
        }
    }
    
    class func getPhotosFromServer(server: String, id: String, secret: String, completion: @escaping (Data?, Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: Endpoints.photoURL(server, id, secret).url) { data, response, error in
            DispatchQueue.main.async {
                completion(data, error)
            }
        }
        task.resume()
    }
    
    class func getPhotosFromStore(url: URL, completion: @escaping (Data?, Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                completion(data, error)
            }
        }
        task.resume()
    }
}




