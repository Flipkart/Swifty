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
    
    static func multipart() -> NetworkResource {
        let json = ["Hello": "World"]
        let data = try! JSONSerialization.data(withJSONObject: json, options: [])
        let image = UIImage(named: "SwiftyLogo")!
        let imageData = UIImagePNGRepresentation(image)!
        return server.post("anything").multipart(data: data, withName: "json", mimeType: "application/json").multipart(data: imageData, withName: "logo", fileName: "SwiftyLogo", mimeType: "image/png")
    }
    
}
