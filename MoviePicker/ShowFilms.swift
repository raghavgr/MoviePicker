//
//  ShowFilms.swift
//  MoviePicker
//
//  Created by Sai Grandhi on 8/18/16.
//  Copyright © 2016 Sai Grandhi. All rights reserved.
//

import UIKit
import CoreData

class ShowFilms: CoreViewController, UITableViewDelegate, UITableViewDataSource,
DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {
    
    var allMovies = [Movie]()
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var image: Photo!

    @IBOutlet var filmsTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Movies"
        let stack = appDelegate.stack
        
        filmsTable.delegate = self
        filmsTable.dataSource = self
        
        // Creating the fetch request
        let fetchRequest = NSFetchRequest(entityName: "Movie")
        fetchRequest.sortDescriptors = []
        fetchRequest.predicate = NSPredicate(format: "photo == %@", self.image)
        
        // Creating the Fetched Results Controller
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
        executeSearch()
    }
    
    // MARK: Core Data Helpers
    func saveCurrentState() {
        do {
            try self.appDelegate.stack.saveContext()
        } catch {
            print("Error while saving from resignActive")
        }
    }
}

extension ShowFilms {

     func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return image.movies!.count
    }
    
     func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let films = image.movies?.allObjects as! [Movie]
        let currFilm = films[indexPath.row]
        var posterImage = UIImage(named: "Movie")
        let cell = tableView.dequeueReusableCellWithIdentifier("savedMovieCell") as UITableViewCell!
        cell.textLabel!.text = currFilm.title
        cell.imageView!.image = nil
        cell.imageView!.contentMode = UIViewContentMode.ScaleAspectFit
        cell.detailTextLabel?.text = "Rating: \(currFilm.rating)"
        
        // Set the Movie Poster Image
        
        if  currFilm.posterPath == nil || currFilm.posterPath == "" {
            posterImage = UIImage(named: "placeholder")
        } else if currFilm.posterImage != nil {
            posterImage = currFilm.posterImage
        }
        
        cell.imageView!.image = posterImage

        return cell
    }
    
     func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        switch editingStyle {
        case .Delete:
            let films = image.movies?.allObjects as! [Movie]
            let currFilm = films[indexPath.row]
            currFilm.photo = nil
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            appDelegate.stack.context.deleteObject(currFilm)
            self.saveCurrentState()
        default:
            break
        }
    }
}

extension ShowFilms {
    func titleForEmptyDataSet(scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "No saved movies 🎬")

    }
    
    func imageForEmptyDataSet(scrollView: UIScrollView) -> UIImage? {
        return UIImage(named: "Movie")
    }
    
    func descriptionForEmptyDataSet(scrollView: UIScrollView) -> NSAttributedString? {
        let text = "Search this image again to get more films"
        return NSAttributedString(string: text, attributes: [
            NSForegroundColorAttributeName: UIColor.grayColor()
            ])
    }
}