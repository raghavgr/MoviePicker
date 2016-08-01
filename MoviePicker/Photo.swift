//
//  Photo.swift
//  
//
//  Created by Sai Grandhi on 8/1/16.
//
//

import Foundation
import CoreData


class Photo: NSManagedObject {

    convenience init(context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context) {
            self.init(entity: ent, insertIntoManagedObjectContext: context)
            self.image = nil
        } else {
            fatalError("unable to find entity name")
        }
    }
    
}
