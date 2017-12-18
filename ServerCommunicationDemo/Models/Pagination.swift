//
//  Pagination.swift
//  ServerCommunicationDemo
//
//  Created by Kokpheng on 12/15/17.
//  Copyright © 2017 Kokpheng. All rights reserved.
//

import Foundation
import SwiftyJSON

class Pagination {
    var page: Int
    var limit: Int
    var totalCount: Int
    var totalPages: Int
    
    init() {
        page = 0
        limit = 0
        totalCount = 0
        totalPages = 0
    }
    
    init(_ data: JSON) {
        page = data["page"].int ?? 0
        limit = data["limit"].int ?? 0
        totalCount = data["total_count"].int ?? 0
        totalPages = data["total_pages"].int ?? 0
    }
}
