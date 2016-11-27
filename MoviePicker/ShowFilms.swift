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
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var image: Photo!

    //button.setImage(UIImage.init(named: "yourImageName.png"), for: UIControlState.normal)
    //button.add
    //button.addTarget(self, action: #selector(ShowFilms.addMovies), for: UIControlEvents.touchUpInside)
    //button.frame = CGRect.init(x: 0, y: 0, width: 30, height: 30) //CGRectMake(0, 0, 30, 30)

    //let addMoviesBtn = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addMovies(sender:)))
    let btn = UIButton(type: .contactAdd)
    
    @IBOutlet var filmsTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Movies"
        let stack = appDelegate.stack
        filmsTable.delegate = self
        filmsTable.dataSource = self
        filmsTable.emptyDataSetSource = self
        filmsTable.emptyDataSetDelegate = self
        btn.addTarget(self, action: #selector(addMovies(sender:)), for: .touchUpInside)
        btn.frame = CGRect.init(x: 0, y: 0, width: 30, height: 30)
        let addMoviesBtn = UIBarButtonItem.init(customView: btn)
        
        self.navigationItem.rightBarButtonItem = addMoviesBtn

        // Creating the fetch request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Movie")
        fetchRequest.sortDescriptors = []
        fetchRequest.predicate = NSPredicate(format: "photo == %@", self.image)
        
        // Creating the Fetched Results Controller
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
        executeSearch()
    }
    
    func addMovies(sender: UIBarButtonItem) {
        print("inside addMovies method")
        let destinationVC = storyboard?.instantiateViewController(withIdentifier: "ShowImageVC") as! ShowImageAndTags
        destinationVC.photo = image
        destinationVC.isSavedPhoto = true
        navigationController?.pushViewController(destinationVC, animated: true)
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

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return image.movies!.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let films = image.movies?.allObjects as! [Movie]
        let currFilm = films[(indexPath as NSIndexPath).row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "savedMovieCell") as UITableViewCell!
        cell?.textLabel!.text = currFilm.title
        cell?.imageView!.contentMode = UIViewContentMode.scaleAspectFit
        cell?.detailTextLabel?.text = "Rating: \(currFilm.rating!)"
        print("\(currFilm.posterPath!)")
        
        
        cell?.imageView!.image = currFilm.posterImage

        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let destinationVC = storyboard?.instantiateViewController(withIdentifier: "movieDetail") as! MovieDetailViewController
        let films = image.movies?.allObjects as! [Movie]
        let currFilm = films[(indexPath as NSIndexPath).row]
        destinationVC.film = currFilm
        navigationController?.pushViewController(destinationVC, animated: true)
    }
    
     func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        switch editingStyle {
        case .delete:
            let films = image.movies?.allObjects as! [Movie]
            let currFilm = films[(indexPath as NSIndexPath).row]
            currFilm.photo = nil
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
            appDelegate.stack.context.delete(currFilm)
            self.saveCurrentState()
        default:
            break
        }
    }
}

extension ShowFilms {
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "No saved movies 🎬")

    }
    
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return UIImage(named: "Movie")
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let text = "Press + to add more movies"
        return NSAttributedString(string: text, attributes: [
            NSForegroundColorAttributeName: UIColor.gray
            ])
    }
}
