//
//  RelatedMovies.swift
//  MoviePicker
//
//  Created by Sai Grandhi on 7/29/16.
//  Copyright © 2016 Sai Grandhi. All rights reserved.
//

import UIKit
import CoreData
class RelatedMovies: CoreViewController, UITableViewDataSource, UITableViewDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

    @IBOutlet var filmsTable: UITableView!
    var keywordResponse: searchKeywordResponse?
    var query: String?
    var keywordID: Int?
    var movies: [TMDBMovie] = [TMDBMovie]()
    var isMoviesLoaded: Bool = false
    var image: Photo!
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    override func viewDidLoad() {
        super.viewDidLoad()
        filmsTable.delegate = self
        filmsTable.dataSource = self
        self.filmsTable.emptyDataSetSource = self
        filmsTable.emptyDataSetDelegate = self
        filmsTable.tableFooterView = UIView()
        query = keywordResponse?.queryName
        print(query!)
        keywordID = keywordResponse!.keywordID
        print(keywordID)
        
        // Core data stuff
        // Setting up a fetch request
        //let stack = appDelegate.stack
        
        // Create   the fetch request
        //let fr = NSFetchRequest(entityName: "Photo")
        //fr.sortDescriptors = []
       // fr.predicate = NSPredicate(format: "pin == %@", self.)
        
        // Create a fetched results controller
        //fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
       // executeSearch()

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // initializing image
        //let currImage = Photo(context: appDelegate.stack.context)
        //image = currImage
        TMDBClient.sharedInstance().getListKeywordID(keywordID!) {
            (results, error) in
            if let results = results {
                self.movies = results
                performUIUpdatesOnMain {
                    self.isMoviesLoaded = true
                    self.filmsTable.reloadData()
                }
            } else {
                print(error)
            }
        }
    }
    
    func saveCurrentState() {
        do {
            try appDelegate.stack.saveContext()
        } catch {
            print("Error while saving from resignActive")
        }
    }

}

// MARK: Table View Functions
extension RelatedMovies {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let reuseID = "movieCell"
        let movie = movies[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseID) as UITableViewCell!
        
        /* Set cell defaults */
        print(movie.title)
        cell.textLabel!.text = movie.title
        cell.imageView!.image = UIImage(named: "Movie")
        cell.imageView!.contentMode = UIViewContentMode.ScaleAspectFit
        cell.detailTextLabel?.text = "Rating: \(movie.vote_avg)"
        if let posterPath = movie.posterPath {
            TMDBClient.sharedInstance().taskForGETImage(TMDBClient.PosterSizes.RowPoster, filePath: posterPath, completionHandlerForImage: { (imageData, error) in
                if let image = UIImage(data: imageData!) {
                    performUIUpdatesOnMain {
                        cell.imageView!.image = image
                    }
                } else {
                    print(error)
                }
            })
        }

        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let saveAction = UITableViewRowAction(style: UITableViewRowActionStyle.Destructive, title: "Save", handler: {(action, indexPath) -> Void in
           // print(self.isTest)
            
            print(self.image.movies!.count)
            let aFilm = self.movies[indexPath.row]
            let currFilm = Movie(film: aFilm, photo: self.image, context: self.appDelegate.stack.context)
            
            var films = self.image.movies?.allObjects as! [Movie]
            films.append(currFilm)
            self.image.image = UIImagePNGRepresentation(SelectedPhoto.selectedImage)
            print("about to save")
            tableView.editing = false
            self.saveCurrentState()
        })
        // Set the button color
        saveAction.backgroundColor = UIColor(red: 28.0/255.0, green: 165.0/255.0, blue: 253.0/255.0, alpha: 1.0)
        return [saveAction]
    }
    
    func titleForEmptyDataSet(scrollView: UIScrollView) -> NSAttributedString? {
        if isMoviesLoaded {
            if movies.count == 0 {
                return NSAttributedString(string: "No movies related to '\(query!)'🙊")
            } else {
                return nil
            }
            
        } else  {
            return NSAttributedString(string: "Getting related movies...")
        }
    }
    func descriptionForEmptyDataSet(scrollView: UIScrollView) -> NSAttributedString? {
        if isMoviesLoaded {
            if movies.count == 0 {
                let text = "The Movie DB could not get more related movies"
                //print("Keyword: inside dzn method for description")
                return NSAttributedString(string: text, attributes: [
                    NSForegroundColorAttributeName: UIColor.grayColor()
                    ])
            } else {
                return nil
            }
        } else {
            let text = "Swipe right to save a movie. 💾"
            print("Keyword: inside dzn method for description")
            return NSAttributedString(string: text, attributes: [
                NSForegroundColorAttributeName: UIColor.grayColor()
                ])
        }
    }
    func imageForEmptyDataSet(scrollView: UIScrollView) -> UIImage? {
        return UIImage(named: "Movie")
    }
    
}
