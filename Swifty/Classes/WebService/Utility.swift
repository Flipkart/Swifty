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

extension Data {
    
    func MIMEType() -> String {
        var value = [UInt8](repeating:0, count:1)
        self.copyBytes(to: &value, count: 1)
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
        return mimeType
    }
}

