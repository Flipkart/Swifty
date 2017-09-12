//
//  IPHeaderInterceptor.swift
//  Swifty
//
//  Created by Siddharth Gupta on 09/09/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import Swifty

class IPHeaderInterceptor: RequestInterceptor {
    
    func intercept(resource: NetworkResource) -> NetworkResource {
        
        if let currentIP = IPConstraint.currentIP {
            print("IPHeaderInterceptor: Added IP Header into the request \(resource.request.url!.absoluteString)")
            resource.header(key: "IP", value: currentIP)
        }
        
        return resource
    }
    
}
