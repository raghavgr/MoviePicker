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

class SavedMoviesCollection: CoreViewController, UICollectionViewDataSource, UICollectionViewDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    @IBOutlet weak var photosCollection: UICollectionView!
    
    var allPhotos = [Photo]()
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var screenSize: CGRect!
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!

    override func viewDidLoad() {
        super.viewDidLoad()
        screenSize = UIScreen.mainScreen().bounds
        screenWidth = screenSize.width
        screenHeight = screenSize.height
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 10, right: 0)
        layout.itemSize = CGSize(width: screenWidth / 3, height: screenWidth / 3)
        
        
        
        photosCollection.delegate = self
        photosCollection.dataSource = self
        photosCollection.collectionViewLayout = layout
        self.automaticallyAdjustsScrollViewInsets = false
        self.photosCollection.emptyDataSetSource = self
        photosCollection.emptyDataSetDelegate = self
        let stack = appDelegate.stack
        let fr = NSFetchRequest(entityName: "Photo")
        fr.sortDescriptors = []
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr,
                                                              managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
        executeSearch()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        executeSearch()
        allPhotos = getPhotos()
        performUIUpdatesOnMain {
            self.photosCollection.reloadData()
        }
        print("pics will appear: \(allPhotos.count)")

    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        executeSearch()
        //allPhotos = getPhotos()
        
        //print("pics did appear: \(allPhotos.count)")

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

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allPhotos.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
       // let pic = allPhotos[indexPath.row]
        //let image = UIImage(data: pic.image!)
        print("inside cellforeItem collection")
        let pic = allPhotos[indexPath.row]
        let anImage = pic.image
        let collectionCellImage = UIImage(data: anImage!)
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! ImageCollectionCell
        cell.imageView.image = collectionCellImage
        
       
        
        //cell.imageView.image = UIImage(named: "placeholder")
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let destinationVC = storyboard?.instantiateViewControllerWithIdentifier("ShowFilmsVC") as! ShowFilms
        let currentPic = allPhotos[indexPath.row]
        destinationVC.image = currentPic
        navigationController?.pushViewController(destinationVC, animated: true)
    }

}

extension SavedMoviesCollection {
    // MARK: DZNEmptyDataSet functions
    func titleForEmptyDataSet(scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "No images selected 📷")
        
    }
    
    func descriptionForEmptyDataSet(scrollView: UIScrollView) -> NSAttributedString? {
        let text = "Add an image and select your films"
        return NSAttributedString(string: text, attributes: [
            NSForegroundColorAttributeName: UIColor.grayColor()
            ])
    }
    
    func imageForEmptyDataSet(scrollView: UIScrollView) -> UIImage? {
        return UIImage(named: "Camera")
    }

}

