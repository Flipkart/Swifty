//
//  NetworkResource Mutation Methods
//  Pods
//
//  Created by Siddharth Gupta on 16/03/17.
//
//

import Foundation

extension NetworkResource {
    
    /// Loads the network resource, and calls the completion block with an unserialized NetworkResponse
    ///
    /// - Parameter completion: completion block to be executed when resource is successfully loaded.
    public func load(completion: @escaping (NetworkResponse) -> Void) {
        
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
    public func load(successBlock: @escaping (_ responseObject: Data?) -> Void, failureBlock: @escaping (_ error: NSError) -> Void) {
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

// MARK: - JSON Loader
extension NetworkResource {
    
    /// Loads the network resource, and calls the successBlock with the parsed JSON, or the failure block with the error.
    ///
    /// - Parameters:
    ///   - readingOptions: JSONSerialization.ReadingOptions, empty by default.
    ///   - successBlock: block to be executed when response doesn't have any errors.
    ///   - failureBlock: block to be executed when response has an error.
    public func loadJSON(readingOptions: JSONSerialization.ReadingOptions = [], successBlock: @escaping (_ responseObject: Any?) -> Void, failureBlock: @escaping (_ error: NSError) -> Void){
        self.parser = JSONParser(readingOptions: readingOptions)
        self.load { (networkResponse) in
            if let json = networkResponse.result {
                successBlock(json)
            } else {
                failureBlock(networkResponse.error!)
            }
        }
    }
    
}
