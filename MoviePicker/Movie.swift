//
//  Movie.swift
//  
//
//  Created by Sai Grandhi on 8/1/16.
//
//

import Foundation
import CoreData


class Movie: NSManagedObject {

    convenience init(dictionary: [String: AnyObject], context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entityForName("Movie", inManagedObjectContext: context) {
            self.init(entity: ent, insertIntoManagedObjectContext: context)
            self.id = dictionary[TMDBClient.JSONResponseKeys.MovieID] as! Int
            self.title = dictionary[TMDBClient.JSONResponseKeys.MovieTitle] as? String
            self.posterPath = dictionary[TMDBClient.JSONResponseKeys.MoviePosterPath] as? String
            self.rating = dictionary[TMDBClient.JSONResponseKeys.MovieVoteAverage] as! Double
            if let dateString = dictionary[TMDBClient.JSONResponseKeys.MovieReleaseDate] as? String {
                if let date = TMDBClient.sharedDateFormatter.dateFromString(dateString) {
                    releaseDate = date
                }
            }
        } else {
            fatalError("Unable to find Entity Name")
        }
    }
    
    var posterImage: UIImage? {
        get {
            return TMDBClient.Caches.imageCache.imageWithIdentifier(posterPath)
        }
        set { TMDBClient.Caches.imageCache.storeImage(newValue, withIdentifier: posterPath!) }
    }
}
