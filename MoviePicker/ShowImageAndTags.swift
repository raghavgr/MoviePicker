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
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!

    //var si: SelectedPhoto = SelectedPhoto.sharedInstance
    let picker = UIImagePickerController()
    var allLabels: Set<String> = []
    // MARK: Alerts
    let customAlert = UIAlertController(title: nil, message: "", preferredStyle: UIAlertControllerStyle.alert)
    let retry = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
    
    // MARK: Bool values for DZNEmpty data set
    var isWordSelected: Bool = false
    var isKeywordsLoaded: Bool = false
    
    // Variables for Keywords table loading
    var keywords: [searchKeywordResponse] = [searchKeywordResponse]()
    var clarifaiString: String = ""

    // MARK: when user loads an existing photo over here
    var photo: Photo!
    var isSavedPhoto: Bool = false
    
    // MARK: Core data 
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // initialising Clarifai Client
        clarifai = ClarifaiClient(appClarifaiID: clarifaiAppID, appClarifaiSecret: clarifaiSecret)
        self.customAlert.addAction(retry)
 
        picker.delegate = self
        reArrangeUIButton.isEnabled = false
        classesTable.delegate = self
        classesTable.dataSource = self
        classesTable.emptyDataSetDelegate = self
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
        
        loadingIndicator.isHidden = true
        
        if isSavedPhoto {
            cleanUpUI(true)
            //resultImage.image = photo.image as! UIImage
            let finalImage = UIImage(data: photo.image! as Data)
            resultImage.image = finalImage
            recognizeImage(finalImage)
            reArrangeUIButton.isEnabled = true
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("why no loading indicator")
        loadingIndicator.isHidden = true
    }
    
    func saveCurrentState() {
        do {
            try self.appDelegate.stack.saveContext()
        } catch {
            print("Error while saving from resignActive")
        }
    }
    
    @IBAction func refreshUI(_ sender: AnyObject) {
        cleanUpUI(false)
    }
    
    /// Re-arrange UI
    func cleanUpUI(_ isPickerOn: Bool) {
        if isPickerOn {
            print("calling true cleanUPUi")
            resultImage.isHidden = false
           classesTable.isHidden = false
            
            //picAdded = true
           addImageButton.isEnabled = false
            addImageButton.isHidden = true
        } else {
            print("calling false cleanUPUi")
            resultImage.image = nil
            resultImage.isHidden = true
            classesTable.isHidden = true
            keywordsTable.isHidden = true
            addImageButton.isEnabled = true
            addImageButton.isHidden = false
            reArrangeUIButton.isEnabled = false
            allLabels = []
            keywords = []
            isWordSelected = false
            isKeywordsLoaded = false
            navigationItem.leftBarButtonItem = nil
            loadingIndicator.isHidden = true
            loadingIndicator.stopAnimating()
            self.keywordsTable.reloadData()
            self.classesTable.reloadData()
        }
    }
    // MARK: Image Picker Functions
    @IBAction func imageSelector(_ sender: AnyObject) {
        reArrangeUIButton.isEnabled = true
        // use actionsheet to select picture source
        let actionSheet = UIAlertController(title: "New Photo", message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: {
           action in
            self.selectFromCamera()
        }))
        actionSheet.addAction(UIAlertAction(title: "Gallery", style: .default, handler: {
            action in
            self.selectFromGallery()
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(actionSheet, animated: true, completion: nil)

    }
    func selectFromCamera() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            picker.sourceType = UIImagePickerControllerSourceType.camera
            self.present(picker, animated: true, completion: nil)
 
        } else {
            customAlert.message = "Camera source not available"
            present(customAlert, animated: true, completion: nil)
        }
    }
    func selectFromGallery() {
        picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        self.present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            resultImage.image = image
            resultImage.contentMode = UIViewContentMode.scaleAspectFill
            resultImage.clipsToBounds = true
            SelectedPhoto.selectedImage = image
            photo = Photo(pic: image, context: self.appDelegate.stack.context)
            self.saveCurrentState()
            loadingIndicator.isHidden = false
            loadingIndicator.startAnimating()
            cleanUpUI(true)
            
            recognizeImage(image)
            
        } else {
            print("Image picker has an error")
        }
        

        dismiss(animated: true, completion: nil)
    }
    
}

// MARK: Clarifai API Interaction

extension ShowImageAndTags {
    func recognizeImage(_ image: UIImage!) {
        clarifai?.recognizeImage(image) {
             (response, error) in
            if error != nil {
                print("Error: \(error)\n")
                self.customAlert.message = "The Internet connection appears to be offline."
                performUIUpdatesOnMain {
                    self.loadingIndicator.stopAnimating()
                    self.present(self.customAlert, animated: true, completion: nil)
                }
            } else {
                
                for tag in (response?.allTags)! {
                    self.allLabels.insert(tag.classLabel)
                    //print(tag.classLabel)
                    performUIUpdatesOnMain {
                        //print("in uiupdate")
                        self.loadingIndicator.stopAnimating()
                        self.classesTable.isHidden = false
                        self.classesTable.reloadData()
                    }
                }
            }
        }
    }
}

// MARK: Tableview methods
extension ShowImageAndTags {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //tableView.reloadData()
        var cell:UITableViewCell?
        if tableView == self.classesTable {
            let CellReuseId = "clarifaiCell"
            cell = tableView.dequeueReusableCell(withIdentifier: CellReuseId) as UITableViewCell!
            let arrLabels = Array(allLabels)
            cell!.textLabel?.text = arrLabels[(indexPath as NSIndexPath).row]
            print(arrLabels[(indexPath as NSIndexPath).row])
            isWordSelected = true
            //return cell
        }
        if tableView == self.keywordsTable {
            let reuseID = "keywordCell"
            //print(reuseID)
            cell = tableView.dequeueReusableCell(withIdentifier: reuseID) as UITableViewCell!
            cell!.textLabel?.text = keywords[(indexPath as NSIndexPath).row].queryName
            //return cell
        }
        return cell!
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print((indexPath as NSIndexPath).row)
        if tableView == self.classesTable {
            //let destinationVC = storyboard?.instantiateViewControllerWithIdentifier("SimilarKeywordVC") as! KeywordSimilarTable
            let arrLabels = Array(allLabels)
            //destinationVC.clarifaiString = arrLabels[indexPath.row]
            //navigationController?.pushViewController(destinationVC, animated: true)
            clarifaiString = arrLabels[(indexPath as NSIndexPath).row]
            isWordSelected = true
            print("isWordSelected value: \(isWordSelected)")
            let backButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: self, action: #selector(ShowImageAndTags.backButton))
            navigationItem.leftBarButtonItem = backButton
            navigationItem.title = "Related Keywords"
            performUIUpdatesOnMain{
                
                self.classesTable.isHidden = true
                //self.classesTable.userInteractionEnabled = false
                self.keywordsTable.isHidden = false
                self.resultImage.isHidden = true
                self.addImageButton.isHidden = true
                self.loadingIndicator.startAnimating()

            }
            _ = TMDBClient.sharedInstance().getMoviesForKeyworfString(clarifaiString) {
                (results, error) in
                if let results = results {
                    self.keywords = results
                    performUIUpdatesOnMain{
                        self.isKeywordsLoaded = true
                        print("value of keywordsLoadedBool: \(self.isKeywordsLoaded)")
                        print("total keywords: \(self.keywords.count)")
                        if self.keywords.count == 0 {
                            print("No Movies related")
                            self.customAlert.message = "Error occured while getting related keywords"
                            performUIUpdatesOnMain {
                                self.loadingIndicator.stopAnimating()
                                
                                self.present(self.customAlert, animated: true, completion: nil)
                            }

                        }
                        self.loadingIndicator.stopAnimating()
                        self.keywordsTable.reloadData()
                    }
                } else {
                    print("No Movies related")
                    self.customAlert.message = "Error occured while getting related keywords"
                    performUIUpdatesOnMain {
                        self.loadingIndicator.stopAnimating()
                        
                        self.present(self.customAlert, animated: true, completion: nil)
                    }
                    self.present(self.customAlert, animated: true, completion: nil)
                    print(error!)
                }
            }
        }
        
        if tableView == self.keywordsTable {
            let destinationVC = storyboard?.instantiateViewController(withIdentifier: "RelatedMoviesVC") as! RelatedMoviesViewController
            destinationVC.keywordResponse = keywords[(indexPath as NSIndexPath).row]
            destinationVC.image = photo
            destinationVC.navigationItem.title = "Related Movies"
            navigationController?.pushViewController(destinationVC, animated: true)
        }
        
    }
    
    // Back button UI functionality
    func backButton() {
        isWordSelected = false
        self.isKeywordsLoaded = false
        self.classesTable.isHidden = false
        self.keywordsTable.isHidden = true
        self.resultImage.isHidden = false
        navigationItem.leftBarButtonItem = nil
        navigationItem.title = "Movie Picker"
    }
    
    
    
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
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

    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
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
                        NSForegroundColorAttributeName: UIColor.gray
                        ])
                } else {
                    return nil
                }
            }
                let text = "The Movie DB will give more related keywords"
                print("Keyword: inside dzn method for description")
                return NSAttributedString(string: text, attributes: [
                    NSForegroundColorAttributeName: UIColor.gray
                    ])
            
        } else {
            let text = "Please wait as the Clarifai API recognizes the image"
            print("inside dzn method for description")
            return NSAttributedString(string: text, attributes: [
                NSForegroundColorAttributeName: UIColor.gray
                ])
        }
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
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
