//
//  Movie+CoreDataProperties.swift
//  
//
//  Created by Sai Grandhi on 8/1/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Movie {

    @NSManaged var id: NSNumber?
    @NSManaged var posterPath: String?
    @NSManaged var releaseDate: NSDate?
    @NSManaged var title: String?
    @NSManaged var rating: NSNumber?
    @NSManaged var photo: Photo?

}