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


/// Built-In response interceptor which runs the given response through it's expected ResponseParser.
class SwiftyParsingInterceptor: ResponseInterceptor {
    
    /// Intercepts the network response, runs throught it's expected ResponseParses and gives back the NetworkResponse.
    ///
    /// - Parameter response: NetworkResponse
    /// - Returns: NetworkResponse
    func intercept(response: NetworkResponse) -> NetworkResponse {
        do {
            try response.parser?.parse(response: response)
        } catch let error {
            response.error = error as NSError
        }
        return response
    }
}

/// Serializes the network response to JSON and throws an error if the parsing fails.
struct JSONParser: ResponseParser {
    
    let readingOptions: JSONSerialization.ReadingOptions
    
    func parse(response: NetworkResponse) throws {
        guard response.error == nil else {
            throw response.error!
        }
        
        if let data = response.data, data.count > 0 {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: readingOptions)
                response.result = json
            }
            catch let error {
                throw SwiftyError.jsonParsingFailure(error: error)
            }
            
        } else {
            throw SwiftyError.responseValidation(reason: "Empty Data Received")
        }
    }
}
