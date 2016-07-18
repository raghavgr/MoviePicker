//
//  GCDBlackBox.swift
//  MoviePicker
//
//  Created by Sai Grandhi on 7/17/16.
//  Copyright © 2016 Sai Grandhi. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(updates: () -> Void) {
    dispatch_async(dispatch_get_main_queue()) {
        updates()
    }
}

