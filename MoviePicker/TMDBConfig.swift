//
//  TMDBConfig.swift
//  MoviePicker
//
//  Created by Sai Grandhi on 7/17/16.
//  Copyright © 2016 Sai Grandhi. All rights reserved.
//

import Foundation

import Foundation

// MARK: - File Support

private let _documentsDirectoryURL: NSURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first as NSURL!
private let _fileURL: NSURL = _documentsDirectoryURL.URLByAppendingPathComponent("TheMovieDB-Context")

// MARK: - TMDBConfig: NSObject, NSCoding

class TMDBConfig: NSObject, NSCoding {
    
    // MARK: Properties
    
    // default values from 1/12/15
    var baseImageURLString = "http://image.tmdb.org/t/p/"
    var secureBaseImageURLString =  "https://image.tmdb.org/t/p/"
    var posterSizes = ["w92", "w154", "w185", "w342", "w500", "w780", "original"]
    var profileSizes = ["w45", "w185", "h632", "original"]
    var dateUpdated: NSDate? = nil
    
    // returns the number days since the config was last updated
    var daysSinceLastUpdate: Int? {
        if let lastUpdate = dateUpdated {
            return Int(NSDate().timeIntervalSinceDate(lastUpdate)) / 60*60*24
        } else {
            return nil
        }
    }
    
    // MARK: Initialization
    
    override init() {}
    
    convenience init?(dictionary: [String:AnyObject]) {
        
        self.init()
        
        if let imageDictionary = dictionary[TMDBClient.JSONResponseKeys.ConfigImages] as? [String:AnyObject],
            let urlString = imageDictionary[TMDBClient.JSONResponseKeys.ConfigBaseImageURL] as? String,
            let secureURLString = imageDictionary[TMDBClient.JSONResponseKeys.ConfigSecureBaseImageURL] as? String,
            let posterSizesArray = imageDictionary[TMDBClient.JSONResponseKeys.ConfigPosterSizes] as? [String],
            let profileSizesArray = imageDictionary[TMDBClient.JSONResponseKeys.ConfigProfileSizes] as? [String] {
            baseImageURLString = urlString
            secureBaseImageURLString = secureURLString
            posterSizes = posterSizesArray
            profileSizes = profileSizesArray
            dateUpdated = NSDate()
        } else {
            return nil
        }
    }
    
    // MARK: Update
    
    func updateIfDaysSinceUpdateExceeds(days: Int) {
        
        // if the config is up to date then return
        if let daysSinceLastUpdate = daysSinceLastUpdate where daysSinceLastUpdate <= days {
            return
        } else {
            updateConfiguration()
        }
    }
    
    private func updateConfiguration() {
        
        TMDBClient.sharedInstance().getConfig() { (didSucceed, error) in
            if let error = error {
                print("Error updating config: \(error.localizedDescription)")
            } else {
                print("Updated Config: \(didSucceed)")
                self.save()
            }
        }
    }
    
    // MARK: NSCoding
    
    let BaseImageURLStringKey = "config.base_image_url_string_key"
    let SecureBaseImageURLStringKey =  "config.secure_base_image_url_key"
    let PosterSizesKey = "config.poster_size_key"
    let ProfileSizesKey = "config.profile_size_key"
    let DateUpdatedKey = "config.date_update_key"
    
    required init(coder aDecoder: NSCoder) {
        baseImageURLString = aDecoder.decodeObjectForKey(BaseImageURLStringKey) as! String
        secureBaseImageURLString = aDecoder.decodeObjectForKey(SecureBaseImageURLStringKey) as! String
        posterSizes = aDecoder.decodeObjectForKey(PosterSizesKey) as! [String]
        profileSizes = aDecoder.decodeObjectForKey(ProfileSizesKey) as! [String]
        dateUpdated = aDecoder.decodeObjectForKey(DateUpdatedKey) as? NSDate
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(baseImageURLString, forKey: BaseImageURLStringKey)
        aCoder.encodeObject(secureBaseImageURLString, forKey: SecureBaseImageURLStringKey)
        aCoder.encodeObject(posterSizes, forKey: PosterSizesKey)
        aCoder.encodeObject(profileSizes, forKey: ProfileSizesKey)
        aCoder.encodeObject(dateUpdated, forKey: DateUpdatedKey)
    }
    
    private func save() {
        NSKeyedArchiver.archiveRootObject(self, toFile: _fileURL.path!)
    }
    
    class func unarchivedInstance() -> TMDBConfig? {
        if NSFileManager.defaultManager().fileExistsAtPath(_fileURL.path!) {
            return NSKeyedUnarchiver.unarchiveObjectWithFile(_fileURL.path!) as? TMDBConfig
        } else {
            return nil
        }
    }
}