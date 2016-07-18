//
//  TMDBConvenience.swift
//  MoviePicker
//
//  Created by Sai Grandhi on 7/17/16.
//  Copyright © 2016 Sai Grandhi. All rights reserved.
//

import Foundation

extension TMDBClient {
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
    
    func getMoviesForKeyworfString(searchString: String, completionHandlerForMovies: (result: [TMDBMovie]?, error: NSError?) -> Void) -> NSURLSessionDataTask? {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let parameters = [TMDBClient.ParameterKeys.Query: searchString]
        
        /* 2. Make the request */
        let task = taskForGETMethod(Methods.SearchKeyword, parameters: parameters) { (results, error) in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                completionHandlerForMovies(result: nil, error: error)
            } else {
                
                if let results = results[TMDBClient.JSONResponseKeys.MovieResults] as? [[String:AnyObject]] {
                    
                    let movies = TMDBMovie.moviesFromResults(results)
                    completionHandlerForMovies(result: movies, error: nil)
                } else {
                    completionHandlerForMovies(result: nil, error: NSError(domain: "getMoviesForSearchString parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getMoviesForSearchString"]))
                }
            }
        }
        
        return task
    }
}