//
//  TMDBConstants.swift
//  MoviePicker
//
//  Created by Sai Grandhi on 7/17/16.
//  Copyright © 2016 Sai Grandhi. All rights reserved.
//

import Foundation

extension TMDBClient {
    
    // MARK: Constants
    struct Constants {
        
        // MARK: API Key
        static let ApiKey : String = "e9666e3d63579e62c9d27861740f41c9"
        
        // MARK: URLs
        static let ApiScheme = "https"
        static let ApiHost = "api.themoviedb.org"
        static let ApiPath = "/3"
    }
    
    // MARK: Methods
    struct Methods {
        
        
        // MARK: Search
        static let SearchKeyword = "/search/keyword"
        
        // MARK: Use keyword ID for movie list
        static let KeywordID = "/keyword/id/movies"
        
        // MARK: Config
        static let Config = "/configuration"
        
    }
    
    // MARK: Parameter Keys
    struct ParameterKeys {
        static let ApiKey = "api_key"
        static let SessionID = "session_id"
        static let RequestToken = "request_token"
        static let Query = "query"
    }
    
    // MARK: JSON Body Keys
    struct JSONBodyKeys {
        static let MediaType = "media_type"
        static let MediaID = "media_id"
        static let Favorite = "favorite"
        static let Watchlist = "watchlist"
    }
    
    // MARK: JSON Response Keys
    struct JSONResponseKeys {
        
        // MARK: General
        static let StatusMessage = "status_message"
        static let StatusCode = "status_code"
        
        // MARK: Authorization
        static let RequestToken = "request_token"
        static let SessionID = "session_id"
        
        // MARK: Account
        static let UserID = "id"
        
        // MARK: Config
        static let ConfigBaseImageURL = "base_url"
        static let ConfigSecureBaseImageURL = "secure_base_url"
        static let ConfigImages = "images"
        static let ConfigPosterSizes = "poster_sizes"
        static let ConfigProfileSizes = "profile_sizes"
        
        // MARK: Movies
        static let MovieID = "id"
        static let MovieTitle = "title"
        static let MoviePosterPath = "poster_path"
        static let MovieReleaseDate = "release_date"
        static let MovieReleaseYear = "release_year"
        static let MovieResults = "results"
        
    }
    
    // MARK: Poster Sizes
    struct PosterSizes {
        static let RowPoster = TMDBClient.sharedInstance().config.posterSizes[2]
        static let DetailPoster = TMDBClient.sharedInstance().config.posterSizes[4]
    }
}