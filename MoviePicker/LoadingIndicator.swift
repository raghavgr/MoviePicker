//
//  LoadingIndicator.swift
//  MoviePicker
//
//  Created by Sai Grandhi on 11/27/16.
//  Copyright © 2016 Sai Grandhi. All rights reserved.
//

import Foundation
import UIKit

class LoadingIndicator {
    
    
    // MARK: programatically adding activity Indicators
    let container: UIView = UIView()
    let actInd: UIActivityIndicatorView = UIActivityIndicatorView()
    let loadingView: UIView = UIView()
    
    func showActivityIndicatory(uiView: UIView) {
        container.frame = uiView.frame
        container.center = uiView.center
        container.backgroundColor = UIColor(red: 255, green: 255, blue: 255, alpha: 0.3)
        
        loadingView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        loadingView.center = uiView.center
        loadingView.backgroundColor = UIColor(red: 68, green: 68, blue: 68, alpha: 0.7)
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        
        actInd.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        actInd.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        actInd.center = CGPoint(x: loadingView.frame.size.width/2, y: loadingView.frame.size.height/2)
        loadingView.addSubview(actInd)
        container.addSubview(loadingView)
        uiView.addSubview(container)
        actInd.startAnimating()
    }
    
    
    func hideActivityIndicator(uiView: UIView) {
        actInd.stopAnimating()
        container.removeFromSuperview()
    }
    // MARK: Shared Instance
    
    class func sharedInstance() -> LoadingIndicator {
        struct Singleton {
            static var sharedInstance = LoadingIndicator()
        }
        return Singleton.sharedInstance
    }
    
}
