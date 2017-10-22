//
//
// Swifty (https://github.com/Flipkart/Swifty)
//
// Copyright 2017 Flipkart Internet Pvt. Ltd.
// Apache License
// Version 2.0, January 2004
//
// See https://github.com/Flipkart/Swifty/blob/master/LICENSE for the full license
//

import Foundation


extension NetworkResource {
    
// MARK: - Resource Load Methods
    
    /// Loads the network resource, and calls the completion block with an unserialized NetworkResponse
    ///
    /// - Parameter completion: completion block to be executed when resource is successfully loaded.
    @objc public func load(completion: @escaping (NetworkResponse) -> Void) {
        
        assert((self.networkInterface != nil), "Your Resource \(self) doesn't have a network interface set. Your network request cannot be fired over the network.")
        
        guard self.networkInterface != nil else {
            completion(NetworkResponse(error: WebServiceError.noNetworkInterface()))
            return
        }
        
        self.networkInterface?.loadResource(resource: self, completion: { response in
            self.deliverOn.async {
                completion(response)
            }
        })
    }
    
    /// Loads the network resource, and calls the success block with unserialized Data and HTTPURLResponse or the failure block with the error
    ///
    /// - Parameters:
    ///   - successBlock: block to be executed when response doesn't have any errors.
    ///   - failureBlock: block to be executed when response has an error.
    @objc public func load(successBlock: @escaping (_ responseObject: Data?) -> Void, failureBlock: @escaping (_ error: NSError) -> Void) {
        self.load { (networkResponse) in
            if let error = networkResponse.error {
                failureBlock(error)
            }
            else {
                successBlock(networkResponse.data)
            }
        }
    }

}


extension NetworkResource {
    
// MARK: - Resource Load Methods (with Parsing)
    
    /// Loads the network resource, and calls the successBlock with the parsed JSON, or the failure block with the error.
    ///
    /// - Parameters:
    ///   - readingOptions: JSONSerialization.ReadingOptions, empty by default.
    ///   - successBlock: block to be executed when response doesn't have any errors.
    ///   - failureBlock: block to be executed when response has an error.
    @objc public func loadJSON(readingOptions: JSONSerialization.ReadingOptions = [], successBlock: @escaping (_ responseObject: Any?) -> Void, failureBlock: @escaping (_ error: NSError) -> Void){
        self.parser = JSONParser(readingOptions: readingOptions)
        self.load { (networkResponse) in
            if let json = networkResponse.result {
                successBlock(json)
            } else {
                if let error = networkResponse.error {
                    failureBlock(error)
                } else {
                    /// No error + No parsed response means a 204/205 Response
                    successBlock(networkResponse.data)
                }
            }
        }
    }
    
}
