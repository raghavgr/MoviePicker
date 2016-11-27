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
        if let ent = NSEntityDescription.entity(forEntityName: "Photo", in: context) {
            self.init(entity: ent, insertInto: context)
            self.image = UIImagePNGRepresentation(pic)
        } else {
            fatalError("unable to find entity name")
        }
    }
    
}
