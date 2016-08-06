//
//  Photo+CoreDataProperties.swift
//  
//
//  Created by Sai Grandhi on 8/5/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Photo {

    @NSManaged var image: NSData?
    @NSManaged var movies: NSSet?

}
