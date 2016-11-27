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
    func getConfig(_ completionHandlerForConfig: @escaping (_ didSucceed: Bool, _ error: NSError?) -> Void) {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let parameters = [String:AnyObject]()
        
        /* 2. Make the request */
        _ = taskForGETMethod(Methods.Config, parameters: parameters) { (results, error) in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                completionHandlerForConfig(false, error)
            } else if let newConfig = TMDBConfig(dictionary: results as! [String:AnyObject]) {
                self.config = newConfig
                completionHandlerForConfig(true, nil)
            } else {
                completionHandlerForConfig(false, NSError(domain: "getConfig parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getConfig"]))
            }
        }
    }
    

    
    // MARK: Keyword search methods
    func getMoviesForKeyworfString(_ searchString: String, completionHandlerForMovies: @escaping (_ result: [searchKeywordResponse]?, _ error: NSError?) -> Void) -> URLSessionDataTask? {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let parameters = [TMDBClient.ParameterKeys.Query: searchString]
        
        /* 2. Make the request */
        let task = taskForGETMethod(Methods.SearchKeyword, parameters: parameters as [String : AnyObject]) { (results, error) in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                completionHandlerForMovies(nil, error)
            } else {
                
                if let results = results?[TMDBClient.JSONResponseKeys.keywordResults] as? [[String:AnyObject]] {
                    var eachKeyword = [searchKeywordResponse]()
                    
                    // iterate through array of dictionaries, each Movie is a dictionary
                    for result in results {
                        eachKeyword.append(searchKeywordResponse(dictionary: result))
                    }
                    
                    completionHandlerForMovies(eachKeyword, nil)
                } else {
                    completionHandlerForMovies(nil, NSError(domain: "getMoviesForKeyworfString parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getMoviesForKeyworfString"]))
                }
            }
        }
        
        return task
    }
    
    // MARK: get list of movies using the keyword id
    func getListKeywordID(_ id: Int, completionHandlerForKeywordID: @escaping (_ result: [TMDBMovie]?, _ error: NSError?) -> ()) -> URLSessionDataTask? {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let parameters = [String:AnyObject]()
        let method = "/keyword/\(id)/movies"
        
        let task = taskForGETMethod(method, parameters: parameters) {
            (results, error) in
            
            if let error = error {
                completionHandlerForKeywordID(nil, error)
            } else {
                if let results = results?[TMDBClient.JSONResponseKeys.MovieResults] as? [[String:AnyObject]] {
                    
                    let movies = TMDBMovie.moviesFromResults(results)
                    completionHandlerForKeywordID(movies, nil)
                } else {
                    completionHandlerForKeywordID(nil, NSError(domain: "getListKeywordID parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getListKeywordID"]))
                }
            }
            
        }
        
        return task
    }
}
