//
//  CoreCollectionViewController.swift
//  MoviePicker
//
//  Created by Sai Grandhi on 8/1/16.
//  Copyright © 2016 Sai Grandhi. All rights reserved.
//

import UIKit
import CoreData

class CoreViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
    var fetchedResultsController : NSFetchedResultsController?{
        didSet{
            // Whenever the frc changes, we execute the search and
            // reload the table
            fetchedResultsController?.delegate = self
            executeSearch()
        }
    }
    
    init(fetchedResultsController fc : NSFetchedResultsController){
        fetchedResultsController = fc
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

// MARK:  - Fetches
extension CoreViewController{
    
    func executeSearch(){
        if let fc = fetchedResultsController{
            do{
                try fc.performFetch()
            }catch let e as NSError{
                print("Error while trying to perform a search: \n\(e)\n\(fetchedResultsController)")
            }
        }
    }
}