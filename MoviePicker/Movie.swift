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


    convenience init(film: TMDBMovie, photo: Photo, reason: String, context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entity(forEntityName: "Movie", in: context) {
            self.init(entity: ent, insertInto: context)
            self.id = film.id as NSNumber? 
            self.title = film.title
            self.posterPath = film.posterPath
            self.rating = film.vote_avg as NSNumber?
            self.whyWatch = reason
            self.photo = photo
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
