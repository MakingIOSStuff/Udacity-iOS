//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by Joel Gans on 8/22/22.
//

import Foundation

class UdacityClient {
    
    // MARK: Auth
    struct Auth {
        static var accountKey = ""
        static var sessionId = ""
    }
    
    // MARK: taskforGetRequest
    class func taskForGETRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionDataTask {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                do {
                    let errorResponse = try decoder.decode(UdacityAPIErrorResponse.self, from: data) as Error
                    DispatchQueue.main.async {
                        completion(nil, errorResponse)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
            }
        }
        task.resume()
        
        return task
    }
    
    class func taskForPostRequest<RequestType: Encodable, ResponseType: Decodable>(shouldSanitize: Bool, body: RequestType, url: URL, values: [String: String], responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionTask { var request = URLRequest(url: url)
        request.httpBody = try! JSONEncoder().encode(body)
        
        for value in values {
            request.addValue(value.value, forHTTPHeaderField: value.key)
        }
        request.httpMethod = "POST"
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) {
            data, response, error in
            if let data = data {
                let jsondecoder = JSONDecoder()
                
                do {
                    let responseObject = shouldSanitize ? try jsondecoder.decode(ResponseType.self, from: sanitizeData(data: data)): try jsondecoder.decode(ResponseType.self, from: data)
                    
                    DispatchQueue.main.async {
                        completion(responseObject, nil)
                    }
                } catch {
                    do {
                        let errorResponse = shouldSanitize ? try jsondecoder.decode(UdacityAPIErrorResponse.self, from: sanitizeData(data: data)) : try jsondecoder.decode(UdacityAPIErrorResponse.self, from: data)
                        
                        DispatchQueue.main.async {
                            completion(nil, errorResponse)
                        }
                    } catch {
                        DispatchQueue.main.async {
                            completion(nil, error)
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
        task.resume()
        return task
    }
    
    // MARK: Login to Udacity
    class func loginUdacityApi(userEmail: String, userPassword: String, completion: @escaping (Bool, Error?) -> Void) {
        let body = sessionRequest(user: User(username: userEmail, password: userPassword))
        
        taskForPostRequest(shouldSanitize: true, body: body, url: EndPoints.EndPoint.createSessionId.url, values: ["Accept": "application/json", "Content-Type": "application/json"], responseType: postSession.self) { (response, error) in
            if let response = response {
                Auth.accountKey = response.account.key
                Auth.sessionId = response.session.id
                completion(true, nil)
            } else {
                completion(false, error)
            }
        }
    }
    
    //MARK: Logout of APP
    class func logout(completion: @escaping (Bool, Error?) -> Void) {
        var request = URLRequest(url: EndPoints.EndPoint.logout.url)
        request.httpMethod = "DELETE"
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error == nil {
                DispatchQueue.main.async {
                    completion(true, nil)
                }
                
            } else {
                DispatchQueue.main.async {
                    completion(false, error)
                }
            }
        }
        task.resume()
    }
    
    // MARK: GetUserData
    class func getUserData(completion: @escaping (userResponse, Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: EndPoints.EndPoint.getUserInfo(userId: Auth.accountKey).url) { (data, response, error) in
                guard let data = data else {
                    DispatchQueue.main.async {
//                        completion(nil, error)
                    }
                    return
                }
                let range = 5..<data.count
                let newData = data.subdata(in: range)
                let decoder = JSONDecoder()
                do {
                    let requestObject = try decoder.decode(userResponse.self, from: newData)
                    DispatchQueue.main.async {
                        print(newData)
                        completion(requestObject, nil)
                    }
                } catch {
                    DispatchQueue.main.async {
//                        completion(nil, error)
                    }
                }
                
            }
            task.resume()
            
        }
//    class func getUserData(completion: @escaping (userResponse?, Error?) -> Void) {
//        taskForGETRequest(url: EndPoints.EndPoint.getUserInfo(userId: Auth.accountKey).url, responseType: userResponse.self) { (response, Error) in
//            if let response = response {
//                completion(response, nil) }
//            else {
//                completion(nil, Error)
//            }
//        }
//    }
    
    // MARK: GetStudentLocations
    class func getAllStudentLocations(completion: @escaping ([studentLocation]?, Error?) -> Void) {
        taskForGETRequest(url: EndPoints.EndPoint.studentLocation.url, responseType: StudentLocationResults.self) { (response, error) in
            if let response = response {
                completion(response.results, nil)
            } else {
                completion(nil, error)
            }
        }
    }
    
    //MARK: Get limited number of student locations
    class func getAllStudentLocationsWithLimit(limit: Int, completion: @escaping ([studentLocation]?, Error?) -> Void) {
        taskForGETRequest(url: EndPoints.EndPoint.studentLocationLimit(limit: limit).url, responseType: StudentLocationResults.self) { (response, error) in
            if let response = response {
                completion(response.results, nil)
            } else {
                completion(nil, error)
            }
        }
    }
    
    //MARK: Post a pin to the map
    class func postPin(user: PostUser, completion: @escaping (Bool, Error?) -> Void) {
        taskForPostRequest(shouldSanitize: false, body: user, url: EndPoints.EndPoint.postUserInfo.url, values: ["Content-Type": "application/json"], responseType: postUserLocationResponse.self) { (response, error) in
            if response != nil {
                completion(true, nil)
            } else {
                completion(false, error)
            }
        }
    }
    //MARK: Sanitize Udacity data
    class func sanitizeData(data: Data) -> Data {
        return data.subdata(in: 5..<data.count)
    }
}
