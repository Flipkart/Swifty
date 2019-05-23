//
//  MultipartUploadTests.swift
//  Swifty_Example
//
//  Created by Siddharth Gupta on 12/08/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import XCTest
import Swifty

class MultipartUploadTests: XCTestCase {
    
    class TestWebService: WebService {
        
        static var serverURL = "https://httpbin.org"
        static var networkInterface: WebServiceNetworkInterface = Swifty()
        
        static func multipartUpload(withImage image: UIImage, name: String) -> NetworkResource {
            let json = ["Hello": "World"]
            let data = try! JSONSerialization.data(withJSONObject: json, options: [])
            let imageData = image.pngData()!
            return server.post("anything").multipart(data: data, withName: "json", mimeType: "application/json").multipart(data: imageData, withName: name, fileName: name, mimeType: "image/png")
        }
        
    }
    
    func testMultipartUploadPayload() {
        
        let expectation = self.expectation(description: "Multipart data uploaded should be received in the response")
        let image = UIImage(named: "SwiftyLogo")!
        let base64Image = image.pngData()!.base64EncodedString()
        
        TestWebService.multipartUpload(withImage: image, name: "logo").loadJSON(successBlock: { (response) in
            XCTAssertNotNil(response)
            XCTAssert(response is [String: Any])
            if let json = response as? [String: Any],
                let form = json["form"] as? [String: Any],
                let files = json["files"] as? [String: Any],
                let logo = files["logo"] as? String,
                let jsonString = form["json"] as? String,
                let data = jsonString.data(using: .utf8),
                let dict = ((try? JSONSerialization.jsonObject(with: data, options: []) as? [String: String])) {
                let base64Data = String(logo.split(separator: ",")[1])
                XCTAssertEqual(base64Data, base64Image)
                XCTAssertEqual(dict, ["Hello": "World"])
                expectation.fulfill()
            }
        }) { (error) in
            XCTFail()
        }
        
        self.waitForExpectations(timeout: 8, handler: nil)
    }
}
