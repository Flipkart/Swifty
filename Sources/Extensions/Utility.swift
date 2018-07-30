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

extension NSNumber {
    internal var isBool: Bool { return CFBooleanGetTypeID() == CFGetTypeID(self) }
}

struct MultiPartDataGenerator {
    static let crlf = "\r\n"
    
    enum BoundaryType {
        case initial
        case middle
        case final
    }
    
    static func boundaryData(for type: BoundaryType, boundary: String) -> Data {
        let boundaryText: String
        
        switch type {
        case .initial:
            boundaryText = "--\(boundary)\(MultiPartDataGenerator.crlf)"
        case .middle:
            boundaryText = "\(MultiPartDataGenerator.crlf)--\(boundary)\(MultiPartDataGenerator.crlf)"
        case .final:
            boundaryText = "\(MultiPartDataGenerator.crlf)--\(boundary)--\(MultiPartDataGenerator.crlf)"
        }
        
        return boundaryText.data(using: String.Encoding.utf8, allowLossyConversion: false)!
    }
}
