//
//  NetworkResourceWithBody.swift
//  Pods
//
//  Created by Chirag Ramani on 09/09/17.
//
//

import Foundation

/// A subclass of NetworkResource, with support for carrying a request body.
public class NetworkResourceWithBody: NetworkResource {}


public extension NetworkResourceWithBody {
// MARK: - Request Modifiers
    /// Sets the HTTP Body of the resource with form encoded data
    ///
    /// Internally sets the Content-Type header of the resource to "application/x-www-form-urlencoded"
    ///
    /// - Parameter dictionary: Dictionary containing key value pairs
    /// - Returns: NetworkResourceWithBody
    @discardableResult func fields(_ dictionary: Dictionary<String, Any>) -> NetworkResourceWithBody {
        
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
    @discardableResult func data(_ data: Data, mimeType: String?) -> NetworkResourceWithBody {
        
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
    @discardableResult func json(body: Dictionary<AnyHashable, Any>, options: JSONSerialization.WritingOptions = []) -> NetworkResourceWithBody {
        
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
    @discardableResult func jsonArray(array: Array<Any>, options: JSONSerialization.WritingOptions = []) -> NetworkResourceWithBody {
        
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
}
