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
    
    fileprivate var inMemoryCache = NSCache<AnyObject, AnyObject>()
    
    // MARK: - Retreiving images
    
    func imageWithIdentifier(_ identifier: String?) -> UIImage? {
        
        // If the identifier is nil, or empty, return nil
        if identifier == nil || identifier! == "" {
            return nil
        }
        
        let path = pathForIdentifier(identifier!)
        
        // First try the memory cache
        if let image = inMemoryCache.object(forKey: path as AnyObject) as? UIImage {
            return image
        }
        
        // Next Try the hard drive
        if let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {
            return UIImage(data: data)
        }
        
        return nil
    }
    
    // MARK: - Saving images
    
    func storeImage(_ image: UIImage?, withIdentifier identifier: String) {
        let path = pathForIdentifier(identifier)
        let data = UIImageJPEGRepresentation(image!, 1.0)!
        try? data.write(to: URL(fileURLWithPath: path), options: [.atomic])
    }
    
    // MARK: deleting images
    func deleteImages(_ identifier: String){
        let path = pathForIdentifier(identifier)
        if FileManager.default.fileExists(atPath: path){
            do {
                try FileManager.default.removeItem(atPath: path)
            } catch {}
            print("deleted \(path)")
        }
    }
    
    // MARK: - Helper
    
    func pathForIdentifier(_ identifier: String) -> String {
        let id = identifier
        let documentsDirectoryURL: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fullURL = documentsDirectoryURL.appendingPathComponent(id)
        
        return fullURL.path
    }
}
