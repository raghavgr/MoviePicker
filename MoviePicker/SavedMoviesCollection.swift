//
//  SavedMoviesCollection.swift
//  MoviePicker
//
//  Created by Sai Grandhi on 8/1/16.
//  Copyright © 2016 Sai Grandhi. All rights reserved.
//

import UIKit
import CoreData
class SavedMoviesCollection: CoreCollectionViewController, UICollectionViewDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    @IBOutlet weak var photosCollection: UICollectionView!
    
    var allPhotos = [Photo]()
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        photosCollection.delegate = self
       // self.photosCollection.emptyDataSetSource = self
       // photosCollection.emptyDataSetDelegate = self
        
        let stack = appDelegate.stack
        let fr = NSFetchRequest(entityName: "Photo")
        fr.sortDescriptors = []
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr,
                                                              managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
        
        allPhotos = getPhotos()
    }
    // MARK: Core Data Helpers
    func saveCurrentState() {
        do {
            try self.appDelegate.stack.saveContext()
        } catch {
            print("Error while saving from resignActive")
        }
    }
    
    func getPhotos() -> [Photo] {
        print("get Photos called")
        let request = NSFetchRequest(entityName: "Photo")
        
        do {
            print("inside do")
            return try self.appDelegate.stack.context.executeFetchRequest(request) as! [Photo]
        } catch {
            print("Get Photos")
            return [Photo]()
        }
    }
}

extension SavedMoviesCollection {

}