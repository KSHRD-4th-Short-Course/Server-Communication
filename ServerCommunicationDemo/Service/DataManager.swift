//
//  DataManager.swift
//  ServerCommunicationDemo
//
//  Created by Kokpheng on 11/18/16.
//  Copyright © 2016 Kokpheng. All rights reserved.
//

import Foundation

struct DataManager {
    struct Url {
        // Define url
        static let BASE = "http://localhost:8080/AMS_API/v1/api/"
        static let AUTH = BASE + "user/authentication"
        static let USER = BASE + "user"
        static let ARTICLE = BASE + "articles"
        static let FILE = BASE + "uploadfile/single"
    }
    
    // Define header
    static let HEADERS = [
        "Authorization" : "Basic QU1TQVBJQURNSU46QU1TQVBJUEBTU1dPUkQ=",
        "Content-Type" : "application/json",
        "Accept" : "application/json"
    ]
}




