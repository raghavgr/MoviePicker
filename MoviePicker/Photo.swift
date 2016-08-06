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

    convenience init(pic: UIImage, context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context) {
            self.init(entity: ent, insertIntoManagedObjectContext: context)
            self.image = UIImagePNGRepresentation(pic)
        } else {
            fatalError("unable to find entity name")
        }
    }
    
}
