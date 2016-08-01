//
//  KeywordSimilarTable.swift
//  MoviePicker
//
//  Created by Sai Grandhi on 7/28/16.
//  Copyright © 2016 Sai Grandhi. All rights reserved.
//

import UIKit

class KeywordSimilarTable: UITableViewController, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    @IBOutlet var keywordsTable: UITableView!
    
    var keywords: [searchKeywordResponse] = [searchKeywordResponse]()
    var clarifaiString: String?
    var isKeywordsLoaded: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        keywordsTable.delegate = self
        self.keywordsTable.emptyDataSetSource = self
        keywordsTable.emptyDataSetDelegate = self
        keywordsTable.tableFooterView = UIView()
        print(clarifaiString!)
        isKeywordsLoaded = false
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        TMDBClient.sharedInstance().getMoviesForKeyworfString(clarifaiString!) {
            (results, error) in
            if let results = results {
                self.keywords = results
                performUIUpdatesOnMain{
                    self.isKeywordsLoaded = true
                    print("value of bool: \(self.isKeywordsLoaded)")
                    self.keywordsTable.reloadData()
                }
            } else {
                print(error)
            }
        }
    }
    
    // MARK: Table View functions
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print(keywords.count)
        return keywords.count
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let reuseID = "keywordTMDBstr"
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseID) as UITableViewCell!
        cell.textLabel?.text = keywords[indexPath.row].queryName
        return cell
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let destinationVC = storyboard?.instantiateViewControllerWithIdentifier("RelatedMoviesVC") as! RelatedMovies
        destinationVC.keywordResponse = keywords[indexPath.row]
        destinationVC.navigationItem.title = "Related Movies"
        navigationController?.pushViewController(destinationVC, animated: true)
    }

    
    // MARK: DZNEmptyDataSet functions
    func titleForEmptyDataSet(scrollView: UIScrollView) -> NSAttributedString? {
        print("inside title DZN for keyword")
        if isKeywordsLoaded {
            if keywords.count == 0 {
            return NSAttributedString(string: "No keywords related to '\(clarifaiString!)'🙊")
            } else {
                return nil
            }
            
        } else  {
            return NSAttributedString(string: "Getting related keywords...")
        }
    }
    
    func descriptionForEmptyDataSet(scrollView: UIScrollView) -> NSAttributedString? {
        if isKeywordsLoaded {
            if keywords.count == 0 {
            let text = "The Movie DB could not get more related keywords"
            //print("Keyword: inside dzn method for description")
            return NSAttributedString(string: text, attributes: [
                NSForegroundColorAttributeName: UIColor.grayColor()
                ])
            } else {
                return nil
            }
        } else {
            let text = "The Movie DB will give more related keywords"
            print("Keyword: inside dzn method for description")
            return NSAttributedString(string: text, attributes: [
                NSForegroundColorAttributeName: UIColor.grayColor()
                ])
        }
    }
    
    func imageForEmptyDataSet(scrollView: UIScrollView) -> UIImage? {
        return UIImage(named: "Keyword")
    }

}
