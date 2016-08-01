//
//  ImageCache.swift
//  MoviePicker
//
//  Created by Sai Grandhi on 8/1/16.
//  Using code written by Jason for FavoriteActors
//      in the old Core Data material
//  Copyright © 2016 Sai Grandhi. All rights reserved.
//

import UIKit

class ImageCache {
    
    private var inMemoryCache = NSCache()
    
    // MARK: - Retreiving images
    
    func imageWithIdentifier(identifier: String?) -> UIImage? {
        
        // If the identifier is nil, or empty, return nil
        if identifier == nil || identifier! == "" {
            return nil
        }
        
        let path = pathForIdentifier(identifier!)
        
        // First try the memory cache
        if let image = inMemoryCache.objectForKey(path) as? UIImage {
            return image
        }
        
        // Next Try the hard drive
        if let data = NSData(contentsOfFile: path) {
            return UIImage(data: data)
        }
        
        return nil
    }
    
    // MARK: - Saving images
    
    func storeImage(image: UIImage?, withIdentifier identifier: String) {
        let path = pathForIdentifier(identifier)
        let data = UIImageJPEGRepresentation(image!, 1.0)!
        data.writeToFile(path, atomically: true)
    }
    
    // MARK: deleting images
    func deleteImages(identifier: String){
        let path = pathForIdentifier(identifier)
        if NSFileManager.defaultManager().fileExistsAtPath(path){
            do {
                try NSFileManager.defaultManager().removeItemAtPath(path)
            } catch {}
            print("deleted \(path)")
        }
    }
    
    // MARK: - Helper
    
    func pathForIdentifier(identifier: String) -> String {
        let id = identifier
        let documentsDirectoryURL: NSURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        let fullURL = documentsDirectoryURL.URLByAppendingPathComponent(id)
        
        return fullURL.path!
    }
}