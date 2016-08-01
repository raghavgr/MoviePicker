//: Playground - noun: a place where people can play

import UIKit
import SwiftyJSON
import Alamofire
// NOTE: Uncommment following two lines for use in a Playground
 import XCPlayground
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
var str = "Hello, playground"
//print("alvin".self.dynamicType)

let url = NSBundle.mainBundle().URLForResource("data", withExtension: "json")
let data = NSData(contentsOfURL: url!)

do {
    let object = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)

} catch {
    // Handle Error
}

class tagResponse: NSObject {
    var classLabel: String
    var probability: Float
    var conceptId: String
    
    init(label: String, prob: Float, conId: String) {
        classLabel = label
        probability = prob
        conceptId = conId
    }
}

class clarifaiResponse {
    var statusCode: String
    var statusMsg: String
    //var results: [apiResult] = [apiResult]()
    var allTags: Array<tagResponse>?
    init(dict: JSON) {
        self.statusCode = dict["status_code"].stringValue
        self.statusMsg = dict["status_msg"].stringValue
        let allResults = dict["results"].arrayValue
        allTags = []
        for aResult in allResults {
            // tested all of this in playground
            let classes = aResult["result"]["tag"]["classes"].arrayObject
            let probabilities = aResult["result"]["tag"]["probs"].arrayObject
            let concepts = aResult["result"]["tag"]["concept_ids"].arrayObject
            
            for (i, classLabel) in classes!.enumerate() {
                let probability = probabilities![i] as! Float
                let concept = concepts![i]
                
                let newTag = tagResponse(label: classLabel as! String, prob: probability, conId: concept as! String)
                allTags?.append(newTag)
            }
        }
    }
}
let aResponse = JSON(data: data!)
let testClarifai = clarifaiResponse(dict: aResponse)
var tagsSet = Set<String>()

print(testClarifai.allTags![19].classLabel)
for tag in testClarifai.allTags! {
    print(tag.classLabel)
    tagsSet.insert(tag.classLabel)
}
tagsSet.count
/**
let timestamp: Float = 1469263452058
let tim: Double = Double(timestamp)/1000
let timeWithNSDate = NSDate.init(timeIntervalSince1970: tim)
*/
let response = JSON(data: data!)

let stat = response["status_code"].rawString()
let classes = response["results"].arrayValue
//classes["result"]
for aResult in classes {
    let tim = aResult["result"]["tag"]["classes"].rawValue
    
   
}
print(response["status_code"].stringValue)


let newURL = NSURL(string: "http://api.themoviedb.org/3/keyword/id/movies")!
let request = NSMutableURLRequest(URL: newURL)
request.addValue("application/json", forHTTPHeaderField: "Accept")

let session = NSURLSession.sharedSession()
let task = session.dataTaskWithRequest(request) { data, response, error in
    if let response = response, data = data {
        print(response)
        print(String(data: data, encoding: NSUTF8StringEncoding))
    } else {
        print(error)
    }
}

task.resume()
/**
var normalText = "Hi am normal"

var boldText  = "And I am BOLD!"

var attributedString = NSMutableAttributedString(string:normalText)

var attrs = [NSFontAttributeName : UIFont.boldSystemFontOfSize(15)]
var boldString = NSMutableAttributedString(string:boldText, attributes:attrs)

attributedString.appendAttributedString(boldString)

print(attributedString)

extension NSMutableAttributedString {
    func bold(text:String) -> NSMutableAttributedString {
        let attrs:[String:AnyObject] = [NSFontAttributeName : UIFont(name: "AvenirNext-Medium", size: 12)!]
        let boldString = NSMutableAttributedString(string:"\(text)", attributes:attrs)
        self.appendAttributedString(boldString)
        return self
    }
    
    func normal(text:String)->NSMutableAttributedString {
        let normal =  NSAttributedString(string: text)
        self.appendAttributedString(normal)
        return self
    }
}
let formattedString = NSMutableAttributedString()
formattedString.bold("Bold Text").normal(" Normal Text ").bold("Bold Text")
*/
