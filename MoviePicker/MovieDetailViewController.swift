//
//  MovieDetailViewController.swift
//  MoviePicker
//
//  Created by Sai Grandhi on 8/24/16.
//  Copyright © 2016 Sai Grandhi. All rights reserved.
//

import UIKit

class MovieDetailViewController: UIViewController {
    
    @IBOutlet weak var posterImage: UIImageView!
    
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var reasonToWatch: UILabel!
    @IBOutlet weak var rating: UILabel!
    
    var film: Movie!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.posterImage.image = film.posterImage
        self.movieTitle.text = film.title
        self.reasonToWatch.text = film.whyWatch
        self.rating.text = "\(film.rating!)"
    }
}
