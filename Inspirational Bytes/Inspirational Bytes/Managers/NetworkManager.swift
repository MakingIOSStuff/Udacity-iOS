//
//  NetworkManager.swift
//  Inspirational Bytes
//
//  Created by Joel Gans on 9/16/22.
//

import Foundation

class NetworkManager {
    
    static let shared = NetworkManager()
    
    enum Endpoints {
        static let base = "https://zenquotes.io/api/"

        case randomQuotesRequest
        case QOTD
        
        var stringValue: String {
            switch self {
            case .randomQuotesRequest:
                return Endpoints.base + "quotes"
            case .QOTD:
                return Endpoints.base + "today"
            }
        }
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    @discardableResult class func taskForGETRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionDataTask {
          let task = URLSession.shared.dataTask(with: url) { data, response, error in
              debugPrint("Tried the get and was got: \(String(describing: response))")
              guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                  print("Error with the response, unexpected status code: \(String(describing: response))")
                  return
              }
              guard let data = data else {
                  debugPrint("The guard statement prevented DECODE")
                  DispatchQueue.main.async {
                      completion(nil, error)
                  }
                  return
              }
              let decoder = JSONDecoder()
              do {
                  debugPrint("We are going to decode now with: \(data) that is \(String(describing: data))")
                  let responseObject = try decoder.decode(responseType, from: data)
                  print("responseObject: \(responseObject)")
                  DispatchQueue.main.async {
                      completion(responseObject, nil)
                  }
              } catch {
                  do {
                      debugPrint("Failed to decode")
                      let errorResponse = try decoder.decode(QuoteResponse.self, from: data) as! Error
                      DispatchQueue.main.async {
                          completion(nil, errorResponse)
                      }
                  } catch {
                      debugPrint("Failed to decode")
                      DispatchQueue.main.async {
                          completion(nil, error)
                      }
                  }
              }
          }
          task.resume()
          
          return task
      }
    
   class func getQuotes(completion: @escaping (QuoteResponse?, Error?) -> Void) {
        NetworkManager.taskForGETRequest(url: Endpoints.randomQuotesRequest.url, responseType: QuoteResponse.self) { response, error in
            print("requested URL: \(Endpoints.randomQuotesRequest.url)")
            if let response = response {
                DispatchQueue.main.async {
                    completion(response, nil)
                }
            } else {
                completion(nil, error)
            }
        }
    }
    
    class func getQOTD(completion: @escaping (QuoteResponse?, Error?) -> Void) {
        NetworkManager.taskForGETRequest(url: Endpoints.QOTD.url, responseType: QuoteResponse.self) { response, error in
            print("requested URL: \(Endpoints.QOTD.url)")
            if let response = response {
                DispatchQueue.main.async {
                    completion(response, nil)
                }
            } else {
                completion(nil, error)
            }
        }
    }
        
        
}
