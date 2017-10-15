//
//  GithubWebService.swift
//  Swifty
//
//  Created by Siddharth Gupta on 09/09/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import Swifty

class HTTPBin: WebService {
    
    static var serverURL = "https://httpbin.org"
    static var networkInterface: WebServiceNetworkInterface = Swifty(constraints: [IPConstraint()],
                                                                     requestInterceptors: [IPHeaderInterceptor()])
   
// MARK: Network Requests
    
    static func getMyIP() -> NetworkResource {
        return server.get("ip")
    }
    
    static func postRequest(with jsonBody: [String: Any]) -> NetworkResource {
        return server.post("post")
                     .json(body: jsonBody)
                     .canHaveConstraints(true)
    }
    
    static func uploadImageRequest(with parameters: [String: Any], multipartData:[MultipartData]) -> NetworkResource {
        return server.post("post")
            .multipart(parameters, multipartData: multipartData)
            .canHaveConstraints(true)
    }
    
}
