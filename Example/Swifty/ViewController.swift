//
//  ViewController.swift
//  Swifty
//
//  Created by Siddharth Gupta on 01/17/2017.
//  Copyright (c) 2017 Siddharth Gupta. All rights reserved.
//

import UIKit
import Swifty

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let body = ["Hello": "HTTP Body"]
        
        HTTPBin.postRequest(with: body).loadJSON(successBlock: { (json) in
            
            if #available(iOS 10.0, *) {
                self.navigationController?.present(SwiftyInspector.presentableInspector(), animated: true, completion: nil)
            }
            
        }) { (error) in
            
            if #available(iOS 10.0, *) {
                self.navigationController?.present(SwiftyInspector.presentableInspector(), animated: true, completion: nil)
            }
            
        }
        uploadImage()
    }
    
    func uploadImage() {
        let parameters = ["comment":"hello"]
        let imageData = UIImagePNGRepresentation(UIImage(named:"SwiftyLogo")!)
        let multipartData = MultipartData(data: imageData!, parameterName: "image")
        HTTPBin.uploadImageRequest(with: parameters, multipartData: [multipartData]).load(successBlock: { (data) in
            print("Image uploaded successfully")
        }) { (error) in
            print("Multipart error : \(error.debugDescription)")
        }
    }
    
}
