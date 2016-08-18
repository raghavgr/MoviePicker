//
//  ShowFilms.swift
//  MoviePicker
//
//  Created by Sai Grandhi on 8/18/16.
//  Copyright © 2016 Sai Grandhi. All rights reserved.
//

import UIKit
import CoreData

class ShowFilms: CoreDataTableViewController, UITableViewDataSource, UITableViewDelegate,
DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {
    
    var allMovies = [Movie]()
    
}

extension ShowFilms {
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        <#code#>
    }
}