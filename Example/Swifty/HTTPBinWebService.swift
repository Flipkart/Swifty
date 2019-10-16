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
    
    var serverURL = "https://httpbin.org"
    var networkInterface: WebServiceNetworkInterface = Swifty(constraints: [IPConstraint()],
                                                                     requestInterceptors: [IPHeaderInterceptor()])
   
// MARK: Network Requests
    
    func getMyIP() -> NetworkResource {
        return server.get("ip")
    }
    
    func postRequest(with jsonBody: [String: Any]) -> NetworkResource {
        return server.post("post")
                     .json(body: jsonBody)
                     .canHaveConstraints(true)
    }
    
}
