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


/// An enum that encapsulates the values considered significant by URLSession for defining task priority.
public enum URLSessionTaskPriority: Float {
    /// low priority (0.1) as defined in URLSessionTask
    case low = 0.1
    /// normal priority (0.5) as defined in URLSessionTask
    case normal = 0.5
    /// high priority (1.0) as defined in URLSessionTask
    case high = 1.0
}

public extension NetworkResource {

// MARK: - Request Modifiers
    
    /// Adds the given credentials as a Basic HTTP Hidden Authorization Header into to the resource.
    ///
    /// The `username` and `password` are **base64 encoded** before being set into the `Authorization` header of request.
    ///
    /// - Parameters:
    ///   - user: The username
    ///   - password: The password
    /// - Returns: NetworkResource
    @objc @discardableResult func authorizationHeader(username: String, password: String) -> NetworkResource {
        
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
    
    /// Adds the given header to the resource, or updates it's value if it already exists.
    ///
    /// - Parameters:
    ///   - key: header name
    ///   - value: header value
    /// - Returns: NetworkResource
    @objc @discardableResult func header(key: String, value: String?) -> NetworkResource {
        
        ///Checking for creation error
        guard self.creationError == nil else {
            return self
        }
        
        guard let value = value else {
            return self
        }
        
        if(value.isEmpty) {
            print("NetworkResource: Didn't add header for key: \(key), since the value provided was empty.")
            return self
        }
        self.request.setValue(value, forHTTPHeaderField: key)
        return self
    }
    
    /// Adds the given headers to the resource, and updates the value of the ones that already exist.
    ///
    /// - Parameter dictionary: Dictionary of header elements.
    /// - Returns: NetworkResource
    @objc @discardableResult func headers(_ dictionary: [String: String]) -> NetworkResource {
        
        guard self.creationError == nil else {
            return self
        }
        
        dictionary.forEach({ (key, value) in
            if(!value.isEmpty) {
                self.request.setValue(value, forHTTPHeaderField: key)
            } else {
                print("NetworkResource: Didn't add header for key: \(key) in the provided headers, since the value provided was empty.")
            }
        })
        return self
    }
    
    /// Encodes the given dictionary into URL Allowed query parameters and adds them to the resource's URL
    ///
    /// - Parameter dictionary: Dictionary containing the query parameters
    /// - Returns: NetworkResource
    @objc @discardableResult func query(_ dictionary: [String: Any]) -> NetworkResource {
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
    
// MARK: - Request Options Modifiers
    
    /// Mocks the response of the resource with the contents of the given filename. Note that if a request is mocked, it'll never hit the network, and will NOT pass the Request Interceptors. It will, however, pass through the Response Intereptors.
    ///
    /// - Parameter withFile: The name (without extension) of the file containing the mocked response. The file must be present in the main bundle (`Bundle.main`)
    /// - Parameter ofType: The extension of the file. Defaults to `.json` if not provided.
    /// - Returns: NetworkResource
    @objc @discardableResult func mock(withFile: String, ofType: String = "json") -> NetworkResource {
        guard let path = Bundle.main.path(forResource: withFile, ofType: ofType), let data = try? Data(contentsOf: URL(fileURLWithPath: path)), data.count > 0 else {
            print("[Swifty] Unable to mock response from file: \(withFile).\(ofType): Make sure the filename and extension are correct, and the file is present in the main bundle of your app. Also make sure the file is not empty.")
            return self
        }
        self.mockedData = data
        return self
    }
    
    /// Sets whether the request should wait for Constraints or not. `false` by default.
    ///
    /// If false, this request will not call any of the given Constraint's methods, and will directly go the the Request Interceptors.
    @objc @discardableResult func canHaveConstraints(_ flag: Bool) -> NetworkResource {
        ///Checking for creation error
        guard self.creationError == nil else {
            return self
        }
        
        self.canHaveConstraints = flag
        return self
    }
    
    /// Sets the priority for the resource to be passed on to URLSession while excuting, defaults to normal priority (0.5)
    @discardableResult func priority(_ priority: URLSessionTaskPriority) -> NetworkResource {
        self.priority = priority
        return self
    }
    
    /// Adds the given tag to the resource
    @objc @discardableResult func tag(_ tag: String) -> NetworkResource {
        self.tags.insert(tag)
        return self
    }
    /// Adds the given tags to the resource
    @objc @discardableResult func tags(_ tags: [String]) -> NetworkResource {
        self.tags.formUnion(tags)
        return self
    }
    
    /// Sets the Queue on which the response should be delivered on. By default, every response is delivered on the main queue.
    @objc @discardableResult func deliverOn(thread: DispatchQueue) -> NetworkResource {
        self.deliverOn = thread
        return self
    }
    
    /// Checks whether the resource has the given tag
    @objc func hasTag(_ tag: String) -> Bool {
        return self.tags.contains(tag)
    }
    
    /// Sets the Content-Type header of the resource.
    ///
    /// - Parameter contentType: Content-Type
    /// - Returns: NetworkResource
    @objc @discardableResult func contentType(_ contentType: String) -> NetworkResource {
        self.request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        return self
    }
    
    /// Constructs the query parameters from the given key and value
    ///
    /// - Parameters:
    ///   - key: key
    ///   - value: value
    /// - Returns: query components.
    internal func queryComponents(fromKey key: String, value: Any) -> [(String, String)] {
        var components: [(String, String)] = []
        
        if let dictionary = value as? [String: Any] {
            for (nestedKey, value) in dictionary {
                components += queryComponents(fromKey: "\(key)[\(nestedKey)]", value: value)
            }
        } else if let array = value as? [String] {
            components += [(key, array.joined(separator: ","))]
        } else if let array = value as? [Any] {
            for value in array {
                components += queryComponents(fromKey: "\(key)[]", value: value)
            }
        } else if let value = value as? NSNumber {
            if value.isBool {
                components.append((escape(key), escape((value.boolValue ? "1" : "0"))))
            } else {
                components.append((escape(key), escape("\(value)")))
            }
        } else if let bool = value as? Bool {
            components.append((escape(key), escape((bool ? "1" : "0"))))
        } else {
            components.append((escape(key), escape("\(value)")))
        }
        
        return components
    }
    
    /// Adds the percent encoding to the string
    ///
    /// - Parameter string: String
    /// - Returns: String
    internal func escape(_ string: String) -> String {
        let generalDelimiters = ":#[]@"
        let subDelimiters = "!$&'()*+,;="
        var allowedCharacterSet = CharacterSet.urlQueryAllowed
        allowedCharacterSet.remove(charactersIn: "\(generalDelimiters)\(subDelimiters)")
        var escaped = ""
        escaped = string.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? string
        return escaped
    }
    
    /// Returns the query.
    ///
    /// - Parameter parameters: parameters
    /// - Returns: String
    internal func getQuery(_ parameters: [String: Any]) -> String {
        var components = [(String, String)]()
        
        for key in parameters.keys.sorted(by: <) {
            let value = parameters[key]!
            components += queryComponents(fromKey: key, value: value)
        }
        
        return components.map { "\($0)=\($1)" }.joined(separator: "&")
    }
}
