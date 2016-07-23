//
//  TMDBConvenience.swift
//  MoviePicker
//
//  Created by Sai Grandhi on 7/17/16.
//  Copyright © 2016 Sai Grandhi. All rights reserved.
//

import Foundation

extension TMDBClient {
    
    // MARK: Method used for movie posters
    func getConfig(completionHandlerForConfig: (didSucceed: Bool, error: NSError?) -> Void) {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let parameters = [String:AnyObject]()
        
        /* 2. Make the request */
        taskForGETMethod(Methods.Config, parameters: parameters) { (results, error) in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                completionHandlerForConfig(didSucceed: false, error: error)
            } else if let newConfig = TMDBConfig(dictionary: results as! [String:AnyObject]) {
                self.config = newConfig
                completionHandlerForConfig(didSucceed: true, error: nil)
            } else {
                completionHandlerForConfig(didSucceed: false, error: NSError(domain: "getConfig parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getConfig"]))
            }
        }
    }
    
    // A struct for keyword response
    struct searchKeywordResponse {
        let keywordID: Int
        let queryName: String
        
        init(dictionary: [String:AnyObject]) {
            keywordID = dictionary[TMDBClient.JSONResponseKeys.keywordID] as! Int
            queryName = dictionary[TMDBClient.JSONResponseKeys.keywordName] as! String
        }
    }
    
    // MARK: Keyword search methods
    func getMoviesForKeyworfString(searchString: String, completionHandlerForMovies: (result: [searchKeywordResponse]?, error: NSError?) -> Void) -> NSURLSessionDataTask? {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let parameters = [TMDBClient.ParameterKeys.Query: searchString]
        
        /* 2. Make the request */
        let task = taskForGETMethod(Methods.SearchKeyword, parameters: parameters) { (results, error) in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                completionHandlerForMovies(result: nil, error: error)
            } else {
                
                if let results = results[TMDBClient.JSONResponseKeys.keywordResults] as? [[String:AnyObject]] {
                    var eachKeyword = [searchKeywordResponse]()
                    
                    // iterate through array of dictionaries, each Movie is a dictionary
                    for result in results {
                        eachKeyword.append(searchKeywordResponse(dictionary: result))
                    }
                    
                    completionHandlerForMovies(result: eachKeyword, error: nil)
                } else {
                    completionHandlerForMovies(result: nil, error: NSError(domain: "getMoviesForKeyworfString parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getMoviesForKeyworfString"]))
                }
            }
        }
        
        return task
    }
    
    // MARK: get list of movies using the keyword id
    func getListKeywordID(id: Int, completionHandlerForKeywordID: (result: [TMDBMovie]?, error: NSError?) -> ()) -> NSURLSessionDataTask? {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let parameters = [String:AnyObject]()
        let method = "/keyword/\(id)/movies"
        
        let task = taskForGETMethod(method, parameters: parameters) {
            (results, error) in
            
            if let error = error {
                completionHandlerForKeywordID(result: nil, error: error)
            } else {
                if let results = results[TMDBClient.JSONResponseKeys.MovieResults] as? [[String:AnyObject]] {
                    
                    let movies = TMDBMovie.moviesFromResults(results)
                    completionHandlerForKeywordID(result: movies, error: nil)
                } else {
                    completionHandlerForKeywordID(result: nil, error:  NSError(domain: "getListKeywordID parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getListKeywordID"]))
                }
            }
            
        }
        
        return task
    }
}