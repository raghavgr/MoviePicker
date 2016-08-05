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

    convenience init(film: TMDBMovie, context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entityForName("Movie", inManagedObjectContext: context) {
            self.init(entity: ent, insertIntoManagedObjectContext: context)
            self.id = film.id 
            self.title = film.title
            self.posterPath = film.posterPath
            self.rating = film.vote_avg
            self.releaseDate = film.releaseYear
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
