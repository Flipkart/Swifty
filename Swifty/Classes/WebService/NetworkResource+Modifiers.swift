//
//  NetworkResource+Modifiers.swift
//  Pods
//
//  Created by Siddharth Gupta on 02/09/17.
//
//

import Foundation


/// URLSessionTaskPriority
///
/// - low: low priority (0.1).
/// - normal: normal priority (0.5).
/// - high: high priority (1.0).
public enum URLSessionTaskPriority: Float {
    case low = 0.1
    case normal = 0.5
    case high = 1.0
}


// MARK: - Request Modifiers
public extension NetworkResource {
    
    /// Adds the given header to the resource, or updates it's value if it already exists.
    ///
    /// - Parameters:
    ///   - key: header name
    ///   - value: header value
    /// - Returns: Network Resource
    @discardableResult func header(key: String, value: String?) -> NetworkResource {
        
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
    /// - Parameter dictionary: Dictionary of header elements.
    /// - Returns: NetworkResource
    @discardableResult func headers(_ dictionary: Dictionary<String, String>) -> NetworkResource {
        
        
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
    
    /// Encodes the given dictionary into URL Allowed query parameters and adds them to the resource's URL
    ///
    /// - Parameter dictionary: Dictionary containing the query parameters
    /// - Returns: NetworkResource
    @discardableResult func query(_ dictionary: Dictionary<String, Any>) -> NetworkResource {
        ///Checking for creation error
        guard self.creationError == nil else {
            return self
        }
        
        guard let baseURL = self.request.url?.absoluteString else {
            self.creationError = WebServiceError.emptyBaseURL()
            return self
        }
        
        let URLWithQueryParams = baseURL + "?" + getQuery(dictionary)
        
        if let url = URL(string: URLWithQueryParams) {
            self.request.url = url
        } else {
            self.creationError = WebServiceError.invalidQueryStringWithURL(url: URLWithQueryParams)
        }
        
        return self
    }
    
// MARK: - Request Options Modifiers
    
    /// Sets whether the request should pass through Constraints or not. False by default.
    @discardableResult func canHaveConstraints(_ flag: Bool) -> NetworkResource {
        ///Checking for creation error
        guard self.creationError == nil else {
            return self
        }
        
        self.canHaveConstraints = flag
        return self
    }
    
    /// Sets the priority for the resource to be passed on to URLSession while excuting, defailts to normal priority (0.5)
    @discardableResult func priority(_ p: URLSessionTaskPriority) -> NetworkResource {
        self.priority = p
        return self
    }
    
    /// Adds the given tag to the resource
    @discardableResult func tag(_ tag: String) -> NetworkResource {
        self.tags.insert(tag)
        return self
    }
    /// Adds the given tags to the resource
    @discardableResult func tags(_ tags: [String]) -> NetworkResource {
        self.tags.formUnion(tags)
        return self
    }
    
    /// Sets the Queue on which the response should be delivered on. By default, every response is delivered on the main queue.
    @discardableResult func deliverOn(thread: DispatchQueue) -> NetworkResource {
        self.deliverOn = thread
        return self
    }
    
    /// Checks whether the resource has the given tag
    func hasTag(_ tag: String) -> Bool {
        return self.tags.contains(tag)
    }
    
    
    /* Utilities */
    
    /*!
     * Prints the request parameters in readable format, including the URL, Headers, Method, and the HTTP Body
     */
    @discardableResult func printDetails() -> NetworkResource {
        print(self.description)
        return self
    }
    
    /// Sets the Content-Type header of the resource.
    ///
    /// - Parameter contentType: Content-Type
    /// - Returns: NetworkResource
    @discardableResult func contentType(_ contentType: String) -> NetworkResource {
        if let _ = self.request.allHTTPHeaderFields {
            self.request.allHTTPHeaderFields!.updateValue(contentType, forKey: "Content-Type")
        }
        else {
            self.request.allHTTPHeaderFields = ["Content-Type": contentType]
        }
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

