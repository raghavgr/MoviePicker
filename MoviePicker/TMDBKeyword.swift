//
//  TMDBKeyword.swift
//  MoviePicker
//
//  Created by Sai Grandhi on 7/28/16.
//  Copyright © 2016 Sai Grandhi. All rights reserved.
//

import Foundation

// A struct for keyword response
struct searchKeywordResponse {
    let keywordID: Int
    let queryName: String
    
    init(dictionary: [String:AnyObject]) {
        keywordID = dictionary[TMDBClient.JSONResponseKeys.keywordID] as! Int
        queryName = dictionary[TMDBClient.JSONResponseKeys.keywordName] as! String
    }
}

// MARK: - TMDBMovie: Equatable

extension searchKeywordResponse: Equatable {}

func ==(lhs: searchKeywordResponse, rhs: searchKeywordResponse) -> Bool {
    return lhs.keywordID == rhs.keywordID
}