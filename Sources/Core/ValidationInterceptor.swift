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

/// Validation Interceptor
struct ValidationInterceptor: ResponseInterceptor {
    
    /// Empty Status Codes
    let emptyStatusCodes: Set<Int> = [204, 205]
    
    /// Valid Status Codes
    let validStatusCodes: [Int] = Array(200..<300)
    
    /// Intercepts the Network Response and validates the response based on its status code.
    ///
    /// - Parameter response: NetworkResponse
    /// - Returns: NetworkResponse
    func intercept(response: NetworkResponse) -> NetworkResponse {
        
        ///Checks Whether response.response is present.
        guard let httpResponse = response.response else {
            return response
        }
        
        /// Valid Status Codes Check
        if(!validStatusCodes.contains(httpResponse.statusCode)) {
            response.fail(error: SwiftyError.responseValidation(reason: "HTTP Status Code \(httpResponse.statusCode)", statusCode: httpResponse.statusCode))
            return response
        }
        
        /// Valid Empty Status Codes Check
        if(response.data?.count == 0 && !emptyStatusCodes.contains(httpResponse.statusCode)){
            response.fail(error: SwiftyError.responseValidation(reason: "Empty Data Received"))
            return response
        }
        
        /// Data Nil Setting in case of Empty Status Code, instead of data with zero count
        if(emptyStatusCodes.contains(httpResponse.statusCode)){
            response.succeed(response: response.response, data: nil)
            // Do Not try to parse the empty data
            response.parser = nil
            return response
        }
        
        return response
    }
}
