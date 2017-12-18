//
//  UserService.swift
//  ServerCommunicationDemo
//
//  Created by Kokpheng on 12/15/17.
//  Copyright © 2017 Kokpheng. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

class UserService {
    
    func singup(paramaters: [String: String], files: [String:Data], completion: @escaping (DataResponse<Any>?, Error?)->()) {
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            
            for (key, value) in paramaters {
                multipartFormData.append(value.data(using: .utf8, allowLossyConversion: false)!, withName: key)
            }
            
            // append image
            for (key, value) in files {
                multipartFormData.append(value, withName: key, fileName: ".jpg",mimeType: "image/jpeg")
            }
            
        }, to: DataManager.Url.USER,
           method: .post,
           headers:  DataManager.HEADERS,
           encodingCompletion: { (encodingResult) in
            
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    completion(response, nil)
                    
                }
            case .failure(let encodingError):
                completion(nil, encodingError)
            }
        })
    }
    
    func signin(paramaters: [String: Any], completion: @escaping (DataResponse<Any>?, Error?)->()) {
        Alamofire.request(DataManager.Url.AUTH, method: .post, parameters: paramaters, encoding: JSONEncoding.default, headers: DataManager.HEADERS)
            // Response from server
            .responseJSON { (response) in
                switch response.result {
                case .success :
                    completion(response, nil)
                case .failure(let encodingError):
                    completion(nil, encodingError)
                    
                }
        }
    }
}
