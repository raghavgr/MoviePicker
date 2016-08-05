//
//  ShowImageAndTags.swift
//  MoviePicker
//
//  Created by Sai Grandhi on 7/22/16.
//  Copyright © 2016 Sai Grandhi. All rights reserved.
//

import UIKit

let clarifaiAppID = "OUBkZhj2F_Ftyk__XWdGl4Y82lW-XpLim7jnNgvz"
let clarifaiSecret = "NTPWquwmNNJIJUZFaTw-t46FvLlaiDyC4zkY3MSD"

var clarifai: ClarifaiClient?
class ShowImageAndTags: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    @IBOutlet weak var addImageButton: UIButton!
    
    @IBOutlet weak var resultImage: UIImageView!
    
    @IBOutlet weak var classesTable: UITableView!
    
    @IBOutlet weak var keywordsTable: UITableView!
    
    @IBOutlet weak var reArrangeUIButton: UIBarButtonItem!
    
    private lazy var client : ClarifaiClient = ClarifaiClient(appClarifaiID: clarifaiAppID, appClarifaiSecret: clarifaiSecret)
    
    var si: SelectedPhoto = SelectedPhoto.sharedInstance
    let picker = UIImagePickerController()
    var allLabels: Set<String> = []
    // MARK: Alerts
    let customAlert = UIAlertController(title: nil, message: "", preferredStyle: UIAlertControllerStyle.Alert)
    let retry = UIAlertAction(title: "Retry", style: UIAlertActionStyle.Cancel, handler: nil)
    
    // MARK: Bool values for DZNEmpty data set
    var isWordSelected: Bool = false
    var isKeywordsLoaded: Bool = false
    
    // Variables for Keywords table loading
    var keywords: [searchKeywordResponse] = [searchKeywordResponse]()
    var clarifaiString: String = ""

    // MARK: when user loads an existing photo over here
    var photo: Photo!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customAlert.addAction(retry)
        // initialising Clarifai Client
        clarifai = ClarifaiClient(appClarifaiID: clarifaiAppID, appClarifaiSecret: clarifaiSecret)
        picker.delegate = self
        reArrangeUIButton.enabled = false
        classesTable.delegate = self
        classesTable.dataSource = self
        classesTable.emptyDataSetSource = self
        self.classesTable.emptyDataSetSource = self
            //classesTable.emptyDataSetDelegate = self

        classesTable.tableFooterView = UIView()
        
        keywordsTable.delegate = self
        keywordsTable.dataSource = self
        self.keywordsTable.emptyDataSetSource = self
        keywordsTable.emptyDataSetDelegate = self
        keywordsTable.tableFooterView = UIView()
        
        isWordSelected = false
        isKeywordsLoaded = false
        self.navigationItem.title = "Movie Picker"
        
    }
    

    
    @IBAction func refreshUI(sender: AnyObject) {
        cleanUpUI(false)
    }
    
    /// Re-arrange UI
    func cleanUpUI(isPickerOn: Bool) {
        if isPickerOn {
            resultImage.hidden = false
           classesTable.hidden = false
            
            //picAdded = true
           addImageButton.enabled = false
            addImageButton.hidden = false
        } else {
            print("calling false cleanUPUi")
            resultImage.image = nil
            resultImage.hidden = true
            classesTable.hidden = true
            keywordsTable.hidden = true
            addImageButton.enabled = true
            addImageButton.hidden = false
            reArrangeUIButton.enabled = false
            allLabels = []
            keywords = []
            isWordSelected = false
            isKeywordsLoaded = false
            navigationItem.leftBarButtonItem = nil
            self.keywordsTable.reloadData()
            self.classesTable.reloadData()
        }
    }
    // MARK: Image Picker Functions
    @IBAction func imageSelector(sender: AnyObject) {
        reArrangeUIButton.enabled = true
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            picker.sourceType = UIImagePickerControllerSourceType.Camera
            self.presentViewController(picker, animated: true, completion: nil)
        } else {
            selectFromGallery()
        }
    }
    
    func selectFromGallery() {
        picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.presentViewController(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        resultImage.image = image
        resultImage.contentMode = UIViewContentMode.ScaleAspectFill
        resultImage.clipsToBounds = true
        SelectedPhoto.selectedImage = image!
        cleanUpUI(true)
        recognizeImage(image)
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}

// MARK: Clarifai API Interaction

extension ShowImageAndTags {
    func recognizeImage(image: UIImage!) {
        clarifai?.recognizeImage(image) {
             (response, error) in
            if error != nil {
                print("Error: \(error)\n")
                self.customAlert.message = "The Internet connection appears to be offline."
                performUIUpdatesOnMain {
                    self.presentViewController(self.customAlert, animated: true, completion: nil)
                }
            } else {
                
                for tag in (response?.allTags)! {
                    self.allLabels.insert(tag.classLabel)
                    //print(tag.classLabel)
                    performUIUpdatesOnMain {
                        //print("in uiupdate")
                        self.classesTable.hidden = false
                        self.classesTable.reloadData()
                    }
                }
            }
        }
    }
}

// MARK: Tableview methods
extension ShowImageAndTags {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print(allLabels.count)
        var count: Int?
        if tableView == self.classesTable {
            count =  allLabels.count
        }
        if tableView == self.keywordsTable {
            print("in numrows for keywords cound: \(keywords.count)")
            count = keywords.count
        }
        return count!
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //tableView.reloadData()
        var cell:UITableViewCell?
        if tableView == self.classesTable {
            let CellReuseId = "clarifaiCell"
            cell = tableView.dequeueReusableCellWithIdentifier(CellReuseId) as UITableViewCell!
            let arrLabels = Array(allLabels)
            cell!.textLabel?.text = arrLabels[indexPath.row]
            //return cell
        }
        if tableView == self.keywordsTable {
            let reuseID = "keywordCell"
            //print(reuseID)
            cell = tableView.dequeueReusableCellWithIdentifier(reuseID) as UITableViewCell!
            cell!.textLabel?.text = keywords[indexPath.row].queryName
            //return cell
        }
        return cell!
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print(indexPath.row)
        if tableView == self.classesTable {
            //let destinationVC = storyboard?.instantiateViewControllerWithIdentifier("SimilarKeywordVC") as! KeywordSimilarTable
            let arrLabels = Array(allLabels)
            //destinationVC.clarifaiString = arrLabels[indexPath.row]
            //navigationController?.pushViewController(destinationVC, animated: true)
            clarifaiString = arrLabels[indexPath.row]
            isWordSelected = true
            print("isWordSelected value: \(isWordSelected)")
            let backButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: #selector(ShowImageAndTags.backButton))
            navigationItem.leftBarButtonItem = backButton
            navigationItem.title = "Related Keywords"
            performUIUpdatesOnMain{
                
                self.classesTable.hidden = true
                //self.classesTable.userInteractionEnabled = false
                self.keywordsTable.hidden = false
                self.resultImage.hidden = true
                self.addImageButton.hidden = true
                

            }
            TMDBClient.sharedInstance().getMoviesForKeyworfString(clarifaiString) {
                (results, error) in
                if let results = results {
                    self.keywords = results
                    performUIUpdatesOnMain{
                        self.isKeywordsLoaded = true
                        print("value of keywordsLoadedBool: \(self.isKeywordsLoaded)")
                        print("total keywords: \(self.keywords.count)")
                       
                        self.keywordsTable.reloadData()
                    }
                } else {
                    print(error)
                }
            }
        }
        
        if tableView == self.keywordsTable {
            let destinationVC = storyboard?.instantiateViewControllerWithIdentifier("RelatedMoviesVC") as! RelatedMovies
            destinationVC.keywordResponse = keywords[indexPath.row]
            destinationVC.navigationItem.title = "Related Movies"
            navigationController?.pushViewController(destinationVC, animated: true)
        }
        
    }
    
    // Back button UI functionality
    func backButton() {
        isWordSelected = false
        self.isKeywordsLoaded = false
        self.classesTable.hidden = false
        self.keywordsTable.hidden = true
        self.resultImage.hidden = false
        navigationItem.leftBarButtonItem = nil
        navigationItem.title = "Movie Picker"
    }
    
    
    
    func titleForEmptyDataSet(scrollView: UIScrollView) -> NSAttributedString? {
        if isWordSelected {
           print("is word selected?")
            if isKeywordsLoaded {
                print("is keywords laoded?")
                if keywords.count == 0 {
                    print("no keywords loaded")
                    return NSAttributedString(string: "No keywords related to '\(clarifaiString)'🙊")
                } else {
                    return nil
                }
            }
            return NSAttributedString(string: "Getting related keywords...")
            
        } else {
            print("inside recognizing")
            return NSAttributedString(string: "Recognizing...")
        }
    }

    func descriptionForEmptyDataSet(scrollView: UIScrollView) -> NSAttributedString? {
        //if isPicAdded  {

       /* } else {
            let text = "Add an image and Clarifai API will speak a 1000 words about that image"
            print("inside dzn method after img added")
            return NSAttributedString(string: text, attributes: [
                NSForegroundColorAttributeName: UIColor.grayColor()
                ])
        }*/
        if isWordSelected {
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
            }
                let text = "The Movie DB will give more related keywords"
                print("Keyword: inside dzn method for description")
                return NSAttributedString(string: text, attributes: [
                    NSForegroundColorAttributeName: UIColor.grayColor()
                    ])
            
        } else {
            let text = "Please wait as the Clarifai API recognizes the image"
            print("inside dzn method for description")
            return NSAttributedString(string: text, attributes: [
                NSForegroundColorAttributeName: UIColor.grayColor()
                ])
        }
    }
    
    func imageForEmptyDataSet(scrollView: UIScrollView) -> UIImage? {
        if isWordSelected {
            return UIImage(named: "Keyword")
        } else {
            return UIImage(named: "Camera")
        }
    }
    
  /**  func emptyDataSetShouldDisplay(scrollView: UIScrollView) -> Bool {
        if allLabels.count > 0 {
            print(allLabels.count)
            return false
        } else  {
            return true
        }
    }*/
    
   
}
