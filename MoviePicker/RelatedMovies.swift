//
//  RelatedMovies.swift
//  MoviePicker
//
//  Created by Sai Grandhi on 7/29/16.
//  Copyright © 2016 Sai Grandhi. All rights reserved.
//

import UIKit

class RelatedMovies: UITableViewController, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

    @IBOutlet var filmsTable: UITableView!
    var keywordResponse: searchKeywordResponse?
    var query: String?
    var keywordID: Int?
    var movies: [TMDBMovie] = [TMDBMovie]()
    var isMoviesLoaded: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        filmsTable.delegate = self
        self.filmsTable.emptyDataSetSource = self
        filmsTable.emptyDataSetDelegate = self
        filmsTable.tableFooterView = UIView()
        query = keywordResponse?.queryName
        print(query!)
        keywordID = keywordResponse!.keywordID
        print(keywordID)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
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
}

extension RelatedMovies {
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
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
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
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
            let text = "The Movie DB will show related movies"
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
