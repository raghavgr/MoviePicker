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
class ShowImageAndTags: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var addImageButton: UIButton!
    
    @IBOutlet weak var resultImage: UIImageView!
    
    @IBOutlet weak var classesTable: UITableView!
    
    @IBOutlet weak var reArrangeUIButton: UIBarButtonItem!
    let picker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // initialising Clarifai Client
        clarifai = ClarifaiClient(appClarifaiID: clarifaiAppID, appClarifaiSecret: clarifaiSecret)
        picker.delegate = self
        reArrangeUIButton.enabled = false
    }
    
    @IBAction func refreshUI(sender: AnyObject) {
        cleanUpUI(false)
    }
    func cleanUpUI(isPickerOn: Bool) {
        if isPickerOn {
            resultImage.hidden = false
            classesTable.hidden = false
          //  addImageButton.enabled = false
           // addImageButton.hidden = false
        } else {
            print("calling false cleanUPUi")
            resultImage.image = nil
            resultImage.hidden = true
            classesTable.hidden = true
            addImageButton.enabled = true
            addImageButton.hidden = false
            reArrangeUIButton.enabled = false
        }
    }
    // MARK: Image Picker Function
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
        resultImage.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        resultImage.contentMode = UIViewContentMode.ScaleAspectFill
        resultImage.clipsToBounds = true
        cleanUpUI(true)
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}
