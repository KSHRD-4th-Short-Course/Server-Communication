//
//  ArticleService.swift
//  ServerCommunicationDemo
//
//  Created by Kokpheng on 12/15/17.
//  Copyright © 2017 Kokpheng. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

protocol ArticleServiceDelegate {
    func didReceivedArticle(with articles: [Article]?, pagination: Pagination?, error: Error?)
    func didReceivedArticle(with article: Article?, error: Error?)
    func didAddedArticle(error: Error?)
    func didUpdatedArticle(error: Error?)
}

extension ArticleServiceDelegate {
    func didReceivedArticle(with articles: [Article]?, pagination: Pagination?, error: Error?) {}
    func didReceivedArticle(with article: Article?, error: Error?) {}
    func didAddedArticle(error: Error?) {}
    func didUpdatedArticle(error: Error?) {}
}

class ArticleService {
    
    var delegate: ArticleServiceDelegate?
    
    func getData(pageNumber: Int) {
        Alamofire.request(DataManager.URL.ARTICLE, parameters: ["page" : pageNumber, "limit" : 5], headers: DataManager.HEADERS)
            .responseJSON { (response) in
                
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    
                    guard let code = json["code"].int, code == 2222 else {
                        // Report any error we got.
                        let dict =  [NSLocalizedDescriptionKey : json["message"].string ?? "unknown"]
                        let error = NSError(domain: response.request?.url?.host ?? "unknown", code: 9999, userInfo: dict)
                        self.delegate?.didReceivedArticle(with: nil, pagination: nil, error: error)
                        return
                    }
                    
                    // get pagination value
                    let pagination = Pagination(json["pagination"])
                    let articles = json["data"].arrayValue.map { Article($0) }
                    
                    self.delegate?.didReceivedArticle(with: articles, pagination: pagination, error: nil)
                    
                case .failure(let error):
                    self.delegate?.didReceivedArticle(with: nil, pagination: nil, error: error)
                }
        }
    }
    
    func getArticle(by id: String) {
        
        // request request book
        Alamofire.request("\(DataManager.URL.ARTICLE)/\(id)",
            method: .get,
            headers: DataManager.HEADERS).responseJSON(completionHandler: { (response) in
                
                switch response.result {
                case.success(let value):
                    
                    let json = JSON(value)
                    
                    guard let code = json["code"].int, code == 2222 else {
                        // Report any error we got.
                        let dict =  [NSLocalizedDescriptionKey : json["message"].string ?? "unknown"]
                        let error = NSError(domain: response.request?.url?.host ?? "unknown", code: 9999, userInfo: dict)
                        self.delegate?.didReceivedArticle(with: nil, pagination: nil, error: error)
                        return
                    }
                    
                    self.delegate?.didReceivedArticle(with: Article(json["data"]), error: nil)
                    
                case.failure(let error):
                    self.delegate?.didReceivedArticle(with: nil, error: error)
                }
            })
    }
    
    
    func addArticle(paramaters: [String: Any]) {
        // request
        Alamofire.request(DataManager.URL.ARTICLE,
                          method: .post,
                          parameters: paramaters,
                          encoding: JSONEncoding.default,
                          headers: DataManager.HEADERS)
            .responseJSON { (response) in
                switch response.result {
                case.success(let value):
                    
                    let json = JSON(value)
                    
                    guard let code = json["code"].int, code == 2222 else {
                        // Report any error we got.
                        let dict =  [NSLocalizedDescriptionKey : json["message"].string ?? "unknown"]
                        let error = NSError(domain: response.request?.url?.host ?? "unknown", code: 9999, userInfo: dict)
                        self.delegate?.didReceivedArticle(with: nil, pagination: nil, error: error)
                        return
                    }
                    
                    self.delegate?.didAddedArticle(error: nil)
                    
                case.failure(let error):
                    self.delegate?.didAddedArticle(error: error)
                }
        }
    }
    
    func updateArticle(with id: String, paramaters: [String: Any]) {
        // request
        Alamofire.request("\(DataManager.URL.ARTICLE)/\(id)",
            method: .put,
            parameters: paramaters,
            encoding: JSONEncoding.default,
            headers: DataManager.HEADERS)
            .responseJSON { (response) in
                switch response.result {
                case.success(let value):
                    
                    let json = JSON(value)
                    
                    guard let code = json["code"].int, code == 2222 else {
                        // Report any error we got.
                        let dict =  [NSLocalizedDescriptionKey : json["message"].string ?? "unknown"]
                        let error = NSError(domain: response.request?.url?.host ?? "unknown", code: 9999, userInfo: dict)
                        self.delegate?.didReceivedArticle(with: nil, pagination: nil, error: error)
                        return
                    }
                    
                    self.delegate?.didUpdatedArticle(error: nil)
                    
                case.failure(let error):
                    self.delegate?.didUpdatedArticle(error: error)
                }
        }
    }
    
    func deleteArticle(with id: String, completion: @escaping (Error?) -> ()) {
        Alamofire.request("\(DataManager.URL.ARTICLE)/\(id)", method: .delete, headers: DataManager.HEADERS).responseJSON { (response) in
            switch response.result {
            case.success(let value):
                
                let json = JSON(value)
                
                guard let code = json["code"].int, code == 2222 else {
                    // Report any error we got.
                    let dict =  [NSLocalizedDescriptionKey : json["message"].string ?? "unknown"]
                    let error = NSError(domain: response.request?.url?.host ?? "unknown", code: 9999, userInfo: dict)
                    self.delegate?.didReceivedArticle(with: nil, pagination: nil, error: error)
                    return
                }
                completion(nil)
            case.failure(let error):
                completion(error)
            }
        }
    }
    
    
    func uploadFile(file : Data, completion: @escaping (String?, Error?) -> ()) {
        /*
         Request :
         - JSONEncoding type creates a JSON representation of the parameters object
         */
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(file, withName: "file", fileName: ".jpg",mimeType: "image/jpeg") // append image
        }, to: DataManager.URL.FILE,
           method: .post,
           headers:  DataManager.HEADERS,
           encodingCompletion: { (encodingResult) in
            
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    if let value = response.result.value {
                        let json = JSON(value)
                        
                        guard let code = json["code"].int, code == 2222 else {
                            // Report any error we got.
                            let dict =  [NSLocalizedDescriptionKey : json["message"].string ?? "unknown"]
                            let error = NSError(domain: response.request?.url?.host ?? "unknown", code: 9999, userInfo: dict)
                            completion(nil, error)
                            return
                        }
                        
                        guard let url = json["data"].string else {
                            // Report any error we got.
                            let dict =  [NSLocalizedDescriptionKey : json["message"].string ?? "unknown"]
                            let error = NSError(domain: response.request?.url?.host ?? "unknown", code: 9999, userInfo: dict)
                            completion(nil, error)
                            return
                        }
                        
                        completion(url, nil)
                    }
                }
            case .failure(let error):
                completion(nil, error)
            }
        })
    }
}
