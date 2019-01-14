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
@objc public class NetworkResourceWithBody: NetworkResource {}

public extension NetworkResourceWithBody {
    
// MARK: - Request Modifiers
    
    /// Adds the given header to the resource, or updates it's value if it already exists.
    ///
    /// - Parameters:
    ///   - key: header name
    ///   - value: header value
    /// - Returns: NetworkResourceWithBody
    @objc @discardableResult override func header(key: String, value: String?) -> NetworkResourceWithBody {
        super.header(key: key, value: value)
        return self
    }
    
    /// Adds the given headers to the resource, and updates the value of the ones that already exist.
    ///
    /// - Parameter dictionary: Dictionary of header key value pairs
    /// - Returns: NetworkResourceWithBody
    @objc @discardableResult override func headers(_ dictionary: Dictionary<String, String>) -> NetworkResourceWithBody {
        super.headers(dictionary)
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
        super.authorizationHeader(username: username, password: password)
        return self
    }
    
    /// Encodes the given dictionary into URL Allowed query parameters and adds them to the resource's URL
    ///
    /// - Parameter dictionary: Dictionary containing the query parameters
    /// - Returns: NetworkResourceWithBody
    @objc @discardableResult override func query(_ dictionary: Dictionary<String, Any>) -> NetworkResourceWithBody {
        super.query(dictionary)
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
        } else {
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
        } else {
            var value = [UInt8](repeating:0, count:1)
            data.copyBytes(to: &value, count: 1)
            var mimeType = "application/octet-stream"
            switch (value[0]) {
            case 0xFF:
                mimeType = "image/jpeg"
            case 0x89:
                mimeType = "image/png"
            case 0x47:
                mimeType = "image/gif"
            case 0x49, 0x4D:
                mimeType = "image/tiff"
            case 0x25:
                mimeType = "application/pdf"
            case 0xD0:
                mimeType = "application/vnd"
            case 0x46:
                mimeType = "text/plain"
            default:
                mimeType = "application/octet-stream"
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
    
    /// Sets the HTTP Body as JSON encoded from a type conforming to the `Encodable (Codable)` protocol
    ///
    /// Internally sets the Content-Type header of the resource to "application/json"
    ///
    /// - Parameters:
    ///   - body: A type conforming to the `Encodable` Protocol
    ///   - options: The `JSONEncoder` instance to use. Defaults to `JSONEncoder()`
    /// - Returns: NetworkResourceWithBody
    @discardableResult func json<T: Encodable>(encodable: T, encoder: JSONEncoder = JSONEncoder()) -> NetworkResourceWithBody {
        
        ///Checking for creation error
        guard self.creationError == nil else {
            return self
        }
        ///Sets the content type
        self.contentType("application/json")
        
        ///Sets the HTTP Body
        do {
            self.request.httpBody = try encoder.encode(encodable)
        }
        catch let error {
            self.creationError = WebServiceError.codableEncodingFailure(error: error)
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
    
    /// Sets the HTTP Body as Multipart Form Data
    ///
    /// Any number of the multipart methods can be chained continuously, the form data will be encoded with the required boundaries when `.load()` is called.
    ///
    /// - Parameters:
    ///   - data: Data
    ///   - name: String
    ///   - mimeType: String (Defaults to application/octet-stream)
    /// - Returns: NetworkResourceWithBody
    @objc @discardableResult func multipart(data: Data, withName name: String, mimeType: String? = "application/octet-stream") -> NetworkResourceWithBody {
        
        ///Checking for creation error
        guard self.creationError == nil else {
            return self
        }
        
        /// Encode the Headers for the multipart data
        let disposition = "form-data; name=\"\(name)\""
        
        var headers: [String: String] = ["Content-Disposition": disposition]
        headers["Content-Type"] = mimeType
        
        var headerText = ""
        for (key, value) in headers {
            headerText += "\(key): \(value)\(MultiPartDataGenerator.delimiter)"
        }
        headerText += MultiPartDataGenerator.delimiter
        
        let encodedHeaders = headerText.data(using: String.Encoding.utf8, allowLossyConversion: false)!
        
        /// Append the Multipart Data into the Array
        if self.multipartData == nil {
            self.multipartData = [BodyPart]()
        }
        
        self.multipartData?.append(BodyPart(headers: encodedHeaders, body: InputStream(data: data)))
        
        return self
    }
    
    /// Sets the HTTP Body as Multipart Form Data
    ///
    /// Any number of the multipart methods can be chained continuously, the form data will be encoded with the required boundaries when `.load()` is called.
    ///
    /// - Parameters:
    ///   - data: Data
    ///   - name: String
    ///   - fileName: String 
    ///   - mimeType: String (Defaults to application/octet-stream)
    /// - Returns: NetworkResourceWithBody
    @objc @discardableResult func multipart(data: Data, withName name: String, fileName: String, mimeType: String? = "application/octet-stream") -> NetworkResourceWithBody {
        
        ///Checking for creation error
        guard self.creationError == nil else {
            return self
        }
        
        /// Encode the Headers for the multipart data
        let disposition = "form-data; name=\"\(name)\"; filename=\"\(fileName)\""
        
        var headers: [String: String] = ["Content-Disposition": disposition]
        headers["Content-Type"] = mimeType
        
        var headerText = ""
        for (key, value) in headers {
            headerText += "\(key): \(value)\(MultiPartDataGenerator.delimiter)"
        }
        headerText += MultiPartDataGenerator.delimiter
        
        let encodedHeaders = headerText.data(using: String.Encoding.utf8, allowLossyConversion: false)!
        
        /// Append the Multipart Data into the Array
        if self.multipartData == nil {
            self.multipartData = [BodyPart]()
        }
        
        self.multipartData?.append(BodyPart(headers: encodedHeaders, body: InputStream(data: data)))
        
        return self
    }
    
    // MARK: - Request Options Modifiers
    
    /// Mocks the response of the resource with the contents of the given filename. Note that if a request is mocked, it'll never hit the network, and will NOT pass the Request Interceptors. It will, however, pass through the Response Intereptors.
    ///
    /// - Parameter withFile: The name (without extension) of the file containing the mocked response. The file must be present in the main bundle (`Bundle.main`)
    /// - Parameter ofType: The extension of the file. Defaults to `.json` if not provided.
    /// - Returns: NetworkResourceWithBody
    @objc @discardableResult override func mock(withFile: String, ofType: String = "json") -> NetworkResourceWithBody {
        super.mock(withFile: withFile, ofType: ofType)
        return self
    }
    
    /// Sets whether the request should wait for Constraints or not. `false` by default.
    ///
    /// If false, this request will not call any of the given Constraint's methods, and will directly go the the Request Interceptors.
    @objc @discardableResult override func canHaveConstraints(_ flag: Bool) -> NetworkResourceWithBody {
        super.canHaveConstraints(flag)
        return self
    }
    
    /// Adds the given tag to the resource
    @objc @discardableResult override func tag(_ tag: String) -> NetworkResourceWithBody {
        super.tag(tag)
        return self
    }
    /// Adds the given tags to the resource
    @objc @discardableResult override func tags(_ tags: [String]) -> NetworkResourceWithBody {
        super.tags(tags)
        return self
    }
    
    /// Sets the Queue on which the response should be delivered on. By default, every response is delivered on the main queue.
    @objc @discardableResult override func deliverOn(thread: DispatchQueue) -> NetworkResourceWithBody {
        super.deliverOn(thread: thread)
        return self
    }
    
    /// Sets the Content-Type header of the resource.
    ///
    /// - Parameter contentType: Content-Type
    /// - Returns: NetworkResourceWithBody
    @objc @discardableResult override func contentType(_ contentType: String) -> NetworkResourceWithBody {
        super.contentType(contentType)
        return self
    }
}
