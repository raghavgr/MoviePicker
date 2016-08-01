//
//  SelectedPhoto.swift
//  MoviePicker
//
//  Created by Sai Grandhi on 8/1/16.
//  Copyright © 2016 Sai Grandhi. All rights reserved.
//

import Foundation

class SelectedPhoto {
    
    static var selectedImage : UIImage = UIImage()
    
    class var sharedInstance: SelectedPhoto {
        struct Singleton {
            static let instance = SelectedPhoto()
        }
        return Singleton.instance
    }
}