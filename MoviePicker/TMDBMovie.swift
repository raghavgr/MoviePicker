//
//  TMDBMovie.swift
//  MoviePicker
//
//  Created by Sai Grandhi on 7/17/16.
//  Copyright © 2016 Sai Grandhi. All rights reserved.
//

import Foundation

struct TMDBMovie {
    
    // MARK: Properties
    
    let title: String
    let id: Int
    let posterPath: String?
    let releaseYear: String?
    
    // MARK: Initializers
    
    // construct a TMDBMovie from a dictionary
    init(dictionary: [String:AnyObject]) {
        title = dictionary[TMDBClient.JSONResponseKeys.MovieTitle] as! String
        id = dictionary[TMDBClient.JSONResponseKeys.MovieID] as! Int
        posterPath = dictionary[TMDBClient.JSONResponseKeys.MoviePosterPath] as? String
        
        if let releaseDateString = dictionary[TMDBClient.JSONResponseKeys.MovieReleaseDate] as? String where releaseDateString.isEmpty == false {
            releaseYear = releaseDateString.substringToIndex(releaseDateString.startIndex.advancedBy(4))
        } else {
            releaseYear = ""
        }
    }
    
    static func moviesFromResults(results: [[String:AnyObject]]) -> [TMDBMovie] {
        
        var movies = [TMDBMovie]()
        
        // iterate through array of dictionaries, each Movie is a dictionary
        for result in results {
            movies.append(TMDBMovie(dictionary: result))
        }
        
        return movies
    }
}

// MARK: - TMDBMovie: Equatable

extension TMDBMovie: Equatable {}

func ==(lhs: TMDBMovie, rhs: TMDBMovie) -> Bool {
    return lhs.id == rhs.id
}