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

struct MultiPartDataGenerator {
    static let delimiter = "\r\n"
    
    enum BoundaryType {
        case initial
        case middle
        case final
    }
    
    static func boundaryData(for type: BoundaryType, boundary: String) -> Data {
        let boundaryText: String
        
        switch type {
        case .initial:
            boundaryText = "--\(boundary)\(MultiPartDataGenerator.delimiter)"
        case .middle:
            boundaryText = "\(MultiPartDataGenerator.delimiter)--\(boundary)\(MultiPartDataGenerator.delimiter)"
        case .final:
            boundaryText = "\(MultiPartDataGenerator.delimiter)--\(boundary)--\(MultiPartDataGenerator.delimiter)"
        }
        
        return boundaryText.data(using: String.Encoding.utf8, allowLossyConversion: false)!
    }
}

/// MultiPart Data Encoding Intercept
struct MultiPartEncodingInterceptor: RequestInterceptor {
    
    /// Intercepts the Network Request and encodes it's multipart form data
    ///
    /// - Parameter response: NetworkResource
    /// - Returns: NetworkResource
    func intercept(resource: NetworkResource) -> NetworkResource {
        
        guard let resourceWithBody = resource as? NetworkResourceWithBody, let parts = resource.multipartData, parts.count > 0 else {
            return resource
        }
        
        let count = parts.count
        let boundary = UUID().uuidString
        let contentType = "multipart/form-data; boundary=\(boundary)"
        var encodedData = MultiPartDataGenerator.boundaryData(for: .initial, boundary: boundary)
        
        for (index, part) in parts.enumerated() {
            encodedData += part + ((index == count - 1) ? MultiPartDataGenerator.boundaryData(for: .final, boundary: boundary) : MultiPartDataGenerator.boundaryData(for: .middle, boundary: boundary))
        }
        
        resourceWithBody.data(encodedData, mimeType: contentType)
        
        return resource
    }
}
