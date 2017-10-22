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

/// A subclass of NetworkResource, with support for carrying a request body.
public class NetworkResourceWithBody: NetworkResource {}


public extension NetworkResourceWithBody {
    
// MARK: - Request Modifiers
    
    /// Adds the given header to the resource, or updates it's value if it already exists.
    ///
    /// - Parameters:
    ///   - key: header name
    ///   - value: header value
    /// - Returns: NetworkResourceWithBody
    @objc @discardableResult override func header(key: String, value: String?) -> NetworkResourceWithBody {
        
        ///Checking for creation error
        guard self.creationError == nil else {
            return self
        }
        
        guard let value = value else {
            return self
        }
        
        if(value.isEmpty){
            print("NetworkResource: Didn't add header for key: \(key), since the value provided was empty.")
            return self
        }
        self.request.setValue(value, forHTTPHeaderField: key)
        return self
    }
    
    /// Adds the given headers to the resource, and updates the value of the ones that already exist.
    ///
    /// - Parameter dictionary: Dictionary of header key value pairs
    /// - Returns: NetworkResourceWithBody
    @objc @discardableResult override func headers(_ dictionary: Dictionary<String, String>) -> NetworkResourceWithBody {
        
        guard self.creationError == nil else {
            return self
        }
        
        dictionary.forEach({ (key, value) in
            if(!value.isEmpty){
                self.request.setValue(value, forHTTPHeaderField: key)
            }
            else {
                print("NetworkResource: Didn't add header for key: \(key) in the provided headers, since the value provided was empty.")
            }
        })
        return self
    }
    
    /// Adds the given credentials as a Basic HTTP Hidden Authorization Header into to the resource.
    ///
    /// The `username` and `password` are **base64 encoded** before being set into the `Authorization` header of request.
    ///
    /// - Parameters:
    ///   - user: The username
    ///   - password: The password
    /// - Returns: NetworkResourceWithBody
    @objc @discardableResult override func authorizationHeader(username: String, password: String) -> NetworkResourceWithBody {
        
        ///Checking for creation error
        guard self.creationError == nil else {
            return self
        }
        
        if let data = "\(username):\(password)".data(using: .utf8) {
            let credential = data.base64EncodedString(options: [])
            self.header(key: "Authorization", value: "Basic \(credential)")
        } else {
            print("NetworkResource: Failed to encode authorization header for \(username): \(password)")
        }
        
        return self
    }
    
    /// Encodes the given dictionary into URL Allowed query parameters and adds them to the resource's URL
    ///
    /// - Parameter dictionary: Dictionary containing the query parameters
    /// - Returns: NetworkResourceWithBody
    @objc @discardableResult override func query(_ dictionary: Dictionary<String, Any>) -> NetworkResourceWithBody {
        ///Checking for creation error
        guard self.creationError == nil else {
            return self
        }
        
        guard let baseURL = self.request.url?.absoluteString else {
            self.creationError = WebServiceError.emptyBaseURL()
            return self
        }
        
        let separator = baseURL.contains("?") ? "&" : "?"
        let URLWithQueryParams = baseURL + separator + getQuery(dictionary)
        
        if let url = URL(string: URLWithQueryParams) {
            self.request.url = url
        } else {
            self.creationError = WebServiceError.invalidQueryStringWithURL(url: URLWithQueryParams)
        }
        
        return self
    }
    
    /// Sets the HTTP Body of the resource with form encoded data
    ///
    /// Internally sets the Content-Type header of the resource to "application/x-www-form-urlencoded"
    ///
    /// - Parameter dictionary: Dictionary containing key value pairs
    /// - Returns: NetworkResourceWithBody
    @objc @discardableResult func fields(_ dictionary: Dictionary<String, Any>) -> NetworkResourceWithBody {
        
        /// Checking for creation error
        guard self.creationError == nil else {
            return self
        }
        /// Sets the content-type
        self.contentType("application/x-www-form-urlencoded")
        
        /// Constructs the query string the input dictionary
        let queryString = getQuery(dictionary)
        
        ///Sets the http body
        if let queryData = queryString.data(using: .utf8) {
            self.request.httpBody = queryData
        }
        else {
            self.creationError = WebServiceError.fieldsEncodingFailure(dictionary: dictionary)
        }
        
        return self
    }
    
    /// Sets the HTTP Body of the resource to the given Data
    ///
    /// - Parameters:
    ///   - data: data to be sent
    ///   - mimeType: MIME/Content-Type to be set in the resource's headers
    /// - Returns: NetworkResourceWithBody
    @objc @discardableResult func data(_ data: Data, mimeType: String?) -> NetworkResourceWithBody {
        
        ///Checking for creation error
        guard self.creationError == nil else {
            return self
        }
        ///Is MIME type available
        if let mimeType = mimeType {
            ///Sets the content type
            self.contentType(mimeType)
        }
        else {
            var value = [UInt8](repeating:0, count:1)
            data.copyBytes(to: &value, count: 1)
            var mimeType = "application/octet-stream"
            switch (value[0]){
            case 0xFF:
                mimeType = "image/jpeg";
            case 0x89:
                mimeType = "image/png";
            case 0x47:
                mimeType = "image/gif";
            case 0x49, 0x4D:
                mimeType = "image/tiff";
            case 0x25:
                mimeType = "application/pdf";
            case 0xD0:
                mimeType = "application/vnd";
            case 0x46:
                mimeType = "text/plain";
            default:
                mimeType = "application/octet-stream";
            }
            self.contentType(mimeType)
        }
        self.request.httpBody = data
        return self
    }
    
    /// Sets the HTTP Body as JSON
    ///
    /// Internally sets the Content-Type header of the resource to "application/json"
    ///
    /// - Parameters:
    ///   - body: key-value pairs
    ///   - options: JSONSerialization.WritingOptions, empty [] by default.
    /// - Returns: NetworkResourceWithBody
    @objc @discardableResult func json(body: Dictionary<AnyHashable, Any>, options: JSONSerialization.WritingOptions = []) -> NetworkResourceWithBody {
        
        ///Checking for creation error
        guard self.creationError == nil else {
            return self
        }
        ///Sets the content type
        self.contentType("application/json")
        
        ///Sets the HTTP Body
        do {
            self.request.httpBody = try JSONSerialization.data(withJSONObject: body, options: options)
        } catch let error {
            self.creationError = WebServiceError.jsonEncodingFailure(dictionary: body, error: error)
        }
        return self
    }
    
    /// Sets the HTTP Body as JSON Array
    ///
    /// Internally sets the Content-Type header of the resource to "application/json"
    ///
    /// - Parameters:
    ///   - body: Array
    ///   - options: JSONSerialization.WritingOptions, empty [] by default.
    /// - Returns: NetworkResourceWithBody
    @objc @discardableResult func jsonArray(array: Array<Any>, options: JSONSerialization.WritingOptions = []) -> NetworkResourceWithBody {
        
        ///Checking for creation error
        guard self.creationError == nil else {
            return self
        }
        ///Sets the content type
        self.contentType("application/json")
        
        ///Sets the HTTP Body
        do {
            self.request.httpBody = try JSONSerialization.data(withJSONObject: array, options: options)
        } catch let error {
            self.creationError = WebServiceError.jsonEncodingFailure(array: array, error: error)
        }
        return self
    }
    
    // MARK: - Request Options Modifiers
    
    /// Sets whether the request should wait for Constraints or not. `false` by default.
    ///
    /// If false, this request will not call any of the given Constraint's methods, and will directly go the the Request Interceptors.
    @objc @discardableResult override func canHaveConstraints(_ flag: Bool) -> NetworkResourceWithBody {
        ///Checking for creation error
        guard self.creationError == nil else {
            return self
        }
        
        self.canHaveConstraints = flag
        return self
    }
    
    /// Adds the given tag to the resource
    @objc @discardableResult override func tag(_ tag: String) -> NetworkResourceWithBody {
        self.tags.insert(tag)
        return self
    }
    /// Adds the given tags to the resource
    @objc @discardableResult override func tags(_ tags: [String]) -> NetworkResourceWithBody {
        self.tags.formUnion(tags)
        return self
    }
    
    /// Sets the Queue on which the response should be delivered on. By default, every response is delivered on the main queue.
    @objc @discardableResult override func deliverOn(thread: DispatchQueue) -> NetworkResourceWithBody {
        self.deliverOn = thread
        return self
    }
    
    /// Sets the Content-Type header of the resource.
    ///
    /// - Parameter contentType: Content-Type
    /// - Returns: NetworkResourceWithBody
    @objc @discardableResult override func contentType(_ contentType: String) -> NetworkResourceWithBody {
        if let _ = self.request.allHTTPHeaderFields {
            self.request.allHTTPHeaderFields!.updateValue(contentType, forKey: "Content-Type")
        }
        else {
            self.request.allHTTPHeaderFields = ["Content-Type": contentType]
        }
        return self
    }
}
