//
//  Photo+CoreDataProperties.swift
//  
//
//  Created by Sai Grandhi on 8/24/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Photo {

    @NSManaged var image: Data?
    @NSManaged var movies: NSSet?

}
