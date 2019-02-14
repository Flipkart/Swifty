//
//
// Swifty (https://github.com/Flipkart/Swifty)
//
// Copyright 2018 Flipkart Internet Pvt. Ltd.
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
        
        return boundaryText.data(using: .utf8, allowLossyConversion: false)!
    }
}

/// A single part in a multi-part body
struct BodyPart {
    let headers: Data
    let body: InputStream
}

/// MultiPart Data Encoding Interceptor
struct MultiPartEncodingInterceptor: RequestInterceptor {
    
    /// Intercepts the Network Request and encodes it's multipart form data, adding the required boundaries.
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
            encodedData += part.headers + encode(inputStream: part.body) + ((index == count - 1) ? MultiPartDataGenerator.boundaryData(for: .final, boundary: boundary) : MultiPartDataGenerator.boundaryData(for: .middle, boundary: boundary))
        }
        
        resourceWithBody.data(encodedData, mimeType: contentType)
        
        return resource
    }
    
    private func encode(inputStream: InputStream) -> Data {
        inputStream.open()
        defer { inputStream.close() }
        
        var encoded = Data()
        
        while inputStream.hasBytesAvailable {
            var buffer = [UInt8](repeating: 0, count: 1024)
            let bytesRead = inputStream.read(&buffer, maxLength: 1024)
            
            if let error = inputStream.streamError {
                print("Stream Error: \(error)")
            }
            
            if bytesRead > 0 {
                encoded.append(buffer, count: bytesRead)
            } else {
                break
            }
        }
        
        return encoded
    }
}

