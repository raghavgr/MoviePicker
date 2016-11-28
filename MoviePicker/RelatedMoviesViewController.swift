//
//  RelatedMoviesViewController.swift
//  MoviePicker
//
//  Created by Sai Grandhi on 8/24/16.
//  Copyright © 2016 Sai Grandhi. All rights reserved.
//

import UIKit
import CoreData
class RelatedMoviesViewController: CoreViewController, UITableViewDataSource, UITableViewDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var activityView: UIView!
    @IBOutlet var filmsTable: UITableView!
    var keywordResponse: searchKeywordResponse?
    var query: String?
    var keywordID: Int?
    var movies: [TMDBMovie] = [TMDBMovie]()
    var isMoviesLoaded: Bool = false
    var hasNoError: Bool = true
    var image: Photo!
    var films = [Movie]()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var reasonForWatching:UITextField = UITextField(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
    let customAlert = UIAlertController(title: nil, message: "", preferredStyle: UIAlertControllerStyle.alert)
    let retry = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
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
        print(keywordID!)
        customAlert.addAction(retry)
        activityView.isHidden = true
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
    
    override func viewDidLayoutSubviews() {
        if let rect = self.navigationController?.navigationBar.frame {
            let y = rect.size.height + rect.origin.y
            self.filmsTable.contentInset = UIEdgeInsetsMake( y, 0, 0, 0)
        }
    }
    // enable tableview and hide the activity indicator
    func activateScreen() {
        self.filmsTable.tableHeaderView?.frame = CGRect(x: 0, y: 0, width: filmsTable.frame.width, height: 0)
        self.filmsTable.tableHeaderView = self.filmsTable.tableHeaderView // necessary to really set the frame
        loadingIndicator.stopAnimating()
    }
    
    // disable tableview animate the activity indicator
    func disactivateScreen() {
        self.filmsTable.tableHeaderView?.frame = filmsTable.frame
        self.filmsTable.tableHeaderView = self.filmsTable.tableHeaderView // necessary to really set the frame
        loadingIndicator.startAnimating()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //self.loadingIndicator.startAnimating()
        disactivateScreen()
        _ = TMDBClient.sharedInstance().getListKeywordID(keywordID!) {
            (results, error) in
            if let results = results {
                self.movies = results
                performUIUpdatesOnMain {
                    //self.activityView.isHidden = true
                    //self.loadingIndicator.hidden = true
                    //self.loadingIndicator.stopAnimating()
                    self.activateScreen()
                    //self.loadingIndicator.hidesWhenStopped = true
                    self.isMoviesLoaded = true
                    self.filmsTable.reloadData()
                }
            } else {
                print("error occured")
                self.activateScreen()
                self.customAlert.message = "Couldn't get related movies"
                self.hasNoError = false
                print(self.hasNoError)
                performUIUpdatesOnMain {
                    self.present(self.customAlert, animated: true, completion: nil)
                }
                print(error!)
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
extension RelatedMoviesViewController {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseID = "movieCell"
        let movie = movies[(indexPath as NSIndexPath).row]
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseID) as UITableViewCell!
        
        /* Set cell defaults */
        print(movie.title)
        cell?.textLabel!.text = movie.title
        cell?.imageView!.image = UIImage(named: "Movie")
        cell?.imageView!.contentMode = UIViewContentMode.scaleAspectFit
        cell?.detailTextLabel?.text = "Rating: \(movie.vote_avg)"
        if let posterPath = movie.posterPath {
            _ = TMDBClient.sharedInstance().taskForGETImage(TMDBClient.PosterSizes.RowPoster, filePath: posterPath, completionHandlerForImage: { (imageData, error) in
                if let image = UIImage(data: imageData!) {
                    performUIUpdatesOnMain {
                        cell?.imageView!.image = image
                    }
                } else {
                    self.hasNoError = false
                    print(error!)
                }
            })
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
    }
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let saveAction = UITableViewRowAction(style: .default, title: "Save", handler: {(action, indexPath) -> Void in
            // print(self.isTest)
            
            print(self.image.movies!.count)
            let aFilm = self.movies[(indexPath as NSIndexPath).row]
            let alertController = UIAlertController(title: "Why watch?", message: "Enter a reason you are interested in this movie", preferredStyle: .alert)
    
            let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
            alertController.addTextField {
                textfield in
                self.reasonForWatching = textfield
                self.reasonForWatching.placeholder = "Enter a reason to watch"
            }
            let save = UIAlertAction(title: "Save", style: .default, handler: {
                saveAction in
                self.saveMovie(aFilm)
            })
            alertController.addAction(save)
            alertController.addAction(cancel)
            self.present(alertController, animated: true, completion: nil)
            tableView.isEditing = false
        })
        // Set the button color
        saveAction.backgroundColor = UIColor(red: 28.0/255.0, green: 165.0/255.0, blue: 253.0/255.0, alpha: 1.0)
        return [saveAction]
    }
    
    func saveMovie(_ aFilm: TMDBMovie) {
        
        let someReason = reasonForWatching.text!
        let currFilm = Movie(film: aFilm, photo: self.image, reason: someReason , context: self.appDelegate.stack.context)        
        self.films = self.image.movies?.allObjects as! [Movie]
        // This first line returns a string representing the second to the smallest size that TheMovieDB serves up
        let size = TMDBClient.sharedInstance().config.posterSizes[1]
        
        // Start the task that will eventually download the image
        _ = TMDBClient.sharedInstance().taskForImageWithSize(size, filePath: currFilm.posterPath!) { data, error in
            
            if let error = error {
                print("Poster download error: \(error.localizedDescription)")
                self.hasNoError = false
            }
            
            if let data = data {
                // Craete the image
                let image = UIImage(data: data)
                
                // update the model, so that the infrmation gets cashed
                currFilm.posterImage = image
                

            }
        }
        self.films.append(currFilm)
        self.image.image = UIImagePNGRepresentation(SelectedPhoto.selectedImage)
     /**   let alertController = UIAlertController(title: "Saved ✅", message: "Saved \(aFilm.title)", preferredStyle: .Alert)
        let save = UIAlertAction(title: "OK", style: .Default, handler: {
            saveAction in
            self.saveMovie(aFilm)
        })
        alertController.addAction(save)
        self.presentViewController(alertController, animated: true, completion: nil)*/
        self.saveCurrentState()
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        if hasNoError {
            if isMoviesLoaded {
                if movies.count == 0 {
                    return NSAttributedString(string: "No movies related to '\(query!)'🙊")
                } else {
                    return nil
                }
                
            } else {
                return NSAttributedString(string: "Getting related movies...")
            }
        } else {
                return NSAttributedString(string: "Error occured ❌")
        
        }
    }

    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        if hasNoError {
            if isMoviesLoaded {
                if movies.count == 0 {
                    let text = "The Movie DB could not get more related movies"
                    //print("Keyword: inside dzn method for description")
                    return NSAttributedString(string: text, attributes: [
                        NSForegroundColorAttributeName: UIColor.gray
                        ])
                } else {
                    return nil
                }
            } else {
                let text = "Swipe right to save a movie. 💾"
                print("Keyword: inside dzn method for description")
                return NSAttributedString(string: text, attributes: [
                    NSForegroundColorAttributeName: UIColor.gray
                    ])
            }
        } else {

                print("hasNoError should be false")
                let text = "There was an error in getting related movies."
                return NSAttributedString(string: text, attributes: [
                    NSForegroundColorAttributeName: UIColor.gray
                    ])
            
        }
    }
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return UIImage(named: "Movie")
    }
    
}
