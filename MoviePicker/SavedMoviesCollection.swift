//
//  SavedMoviesCollection.swift
//  MoviePicker
//
//  Created by Sai Grandhi on 8/1/16.
//  Copyright © 2016 Sai Grandhi. All rights reserved.
//

import UIKit
import CoreData
private let reuseIdentifier = "imageCollectionCell"

class SavedMoviesCollection: CoreViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var photosCollection: UICollectionView!
    
    var allPhotos = [Photo]()
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        photosCollection.delegate = self
        photosCollection.dataSource = self
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
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
       // let pic = allPhotos[indexPath.row]
        //let image = UIImage(data: pic.image!)
        print("inside cellforeItem collection")
        let collectionCellImage = UIImage(named: "Camera")
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! ImageCollectionCell
        cell.imageView.image = collectionCellImage
        return cell
    }
}

