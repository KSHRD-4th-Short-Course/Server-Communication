//
//  Author.swift
//  ServerCommunicationDemo
//
//  Created by Kokpheng on 12/15/17.
//  Copyright © 2017 Kokpheng. All rights reserved.
//

import Foundation
import SwiftyJSON

class Author {
    var id: Int
    var name: String
    var email: String
    var gender: String
    var status: String
    var imageUrl: String
    
    init(_ data: JSON) {
        id = data["id"].int ?? 0
        name = data["name"].string ?? ""
        email = data["email"].string ?? ""
        gender = data["gender"].string ?? ""
        status = data["status"].string ?? ""
        imageUrl = data["image_url"].string ?? ""
    }
    
}
