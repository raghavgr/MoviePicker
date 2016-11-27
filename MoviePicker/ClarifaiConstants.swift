//
//  ClarifaiConstants.swift
//  MoviePicker
//
//  Created by Sai Grandhi on 7/15/16.
//  Copyright © 2016 Sai Grandhi. All rights reserved.
//

import Foundation

extension ClarifaiClient {
    
    struct Config {
        static let APIBaseURL: String = "https://api.clarifai.com/v1"
        static let clientID: String = "com.MoviePicker.clientID"
        static let clientSecret: String = "com.MoviePicker.clientSecret"
        static let AccessToken: String = "com.MoviePicker.AccessToken"
        static let AccessTokenExpiryTime: String = "com.MoviePicker.AccessTokenExpiryTime"
        static let MinimumTokenTime: TimeInterval = 60
    }
}
