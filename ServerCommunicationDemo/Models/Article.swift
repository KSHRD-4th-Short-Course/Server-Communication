//
//  Book.swift
//  ServerCommunicationDemo
//
//  Created by Kokpheng on 11/15/16.
//  Copyright © 2016 Kokpheng. All rights reserved.
//

import Foundation
import SwiftyJSON

class Article {
    var id: Int
    var title : String
    var description : String
    var createdDate : String
    var author : Author
    var status : String
    var category : Category
    var imageUrl : String
    
    init(_ data: JSON) {
        id = data["id"].int ?? 0
        title = data["title"].string ?? ""
        description = data["description"].string ?? ""
        createdDate = data["created_date"].string ?? ""
        author = Author(data["author"])
        status = data["status"].string ?? ""
        category = Category(data["category"])
        imageUrl = data["image_url"].string ?? ""
    }
}


