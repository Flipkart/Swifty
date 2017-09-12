//
//  IPConstraint.swift
//  Swifty
//
//  Created by Siddharth Gupta on 09/09/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import Swifty

class IPConstraint: Constraint {
    
    static var currentIP: String?
    
    enum ConstraintError: Error {
        case invalidIPReceived
    }
    
    override func isConstraintSatisfied(for resource: NetworkResource) -> Bool {
        
        if let _ = IPConstraint.currentIP {
            return true
        }
        
        return false
    }
    
    override func satisfyConstraint(for resource: NetworkResource) {
        
        HTTPBin.getMyIP().loadJSON(successBlock: { (response) in
            
            guard let json = response as? [String: Any], let myIP = json["origin"] as? String else {
                self.finish(with: ConstraintError.invalidIPReceived)
                return
            }
            
            IPConstraint.currentIP = myIP
            print("IPConstraint: Got the IP from server, constraint satisfied!")
            self.finish(with: nil)
            
        }) { (error) in
            self.finish(with: error)
        }
        
    }
    
}
