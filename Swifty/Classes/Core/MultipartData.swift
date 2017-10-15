//
//  MultipartData.swift
//
//  Created by Sunil Sharma on 15/10/17.
//

import Foundation

public struct MultipartData {
    private let data: Data
    private let parameterName: String
    private let filename: String?
    private let mimeType: String
    
    public init(data: Data, parameterName:String, filename:String? = nil, mimeType:String? = nil) {
        self.data = data
        self.parameterName = parameterName
        self.filename = filename
        if let mimeType = mimeType {
            self.mimeType = mimeType
        } else {
            self.mimeType = data.MIMEType()
        }
    }
    
    internal func getFormData(boundary:String) -> Data {
        var body = ""
        body += "--\(boundary)\r\n"
        body += "Content-Disposition: form-data; "
        body += "name=\"\(parameterName)\""
        if let filename = filename {
            body += "; filename=\"\(filename)\""
        }
        body += "\r\n"
        body += "Content-Type: \(mimeType)\r\n\r\n"
        
        var bodyData = Data()
        if let data = body.data(using: .utf8) {
            bodyData.append(data)
        } else {
            assertionFailure("Unable to encode fields name \(parameterName) \(filename == nil ? "" : "and") \(filename ?? "") to data using .utf8 encoding.")
        }
        bodyData.append(data)
        bodyData.append("\r\n".data(using: .utf8)!)
        return bodyData
    }
}
