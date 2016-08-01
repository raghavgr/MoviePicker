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
    
    @IBOutlet weak var reArrangeUIButton: UIBarButtonItem!
    
    private lazy var client : ClarifaiClient = ClarifaiClient(appClarifaiID: clarifaiAppID, appClarifaiSecret: clarifaiSecret)
    
    var si: SelectedPhoto = SelectedPhoto.sharedInstance
    let picker = UIImagePickerController()
    var allLabels: Set<String> = []
    // MARK: Alerts
    let customAlert = UIAlertController(title: nil, message: "", preferredStyle: UIAlertControllerStyle.Alert)
    let retry = UIAlertAction(title: "Retry", style: UIAlertActionStyle.Cancel, handler: nil)
    
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
           // addImageButton.enabled = false
           // addImageButton.hidden = false
        } else {
            print("calling false cleanUPUi")
            resultImage.image = nil
            resultImage.hidden = true
            classesTable.hidden = true
            addImageButton.enabled = true
            addImageButton.hidden = false
            reArrangeUIButton.enabled = false
            allLabels = []
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
        return allLabels.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //tableView.reloadData()
        let CellReuseId = "clarifaiCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(CellReuseId) as UITableViewCell!
        let arrLabels = Array(allLabels)
        cell.textLabel?.text = arrLabels[indexPath.row]
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print(indexPath.row)
        let destinationVC = storyboard?.instantiateViewControllerWithIdentifier("SimilarKeywordVC") as! KeywordSimilarTable
        let arrLabels = Array(allLabels)
        destinationVC.clarifaiString = arrLabels[indexPath.row]
        navigationController?.pushViewController(destinationVC, animated: true)
        
    }
    
    
    
    func titleForEmptyDataSet(scrollView: UIScrollView) -> NSAttributedString? {
       // if isPicAdded {
            print("inside recognizing")
            return NSAttributedString(string: "Recognizing...")
            
       /* } else  {
            print("inside no recognition")
            return NSAttributedString(string: "No Recognition")
        }*/
    }

    func descriptionForEmptyDataSet(scrollView: UIScrollView) -> NSAttributedString? {
        //if isPicAdded  {
            let text = "Please wait as the Clarifai API recognizes the image"
            print("inside dzn method for description")
            return NSAttributedString(string: text, attributes: [
                NSForegroundColorAttributeName: UIColor.grayColor()
                ])
       /* } else {
            let text = "Add an image and Clarifai API will speak a 1000 words about that image"
            print("inside dzn method after img added")
            return NSAttributedString(string: text, attributes: [
                NSForegroundColorAttributeName: UIColor.grayColor()
                ])
        }*/
    }
    
    func imageForEmptyDataSet(scrollView: UIScrollView) -> UIImage? {
        return UIImage(named: "Camera")
    }
    
    func emptyDataSetShouldDisplay(scrollView: UIScrollView) -> Bool {
        if allLabels.count > 0 {
            print(allLabels.count)
            return false
        } else  {
            return true
        }
    }
    
   
}
