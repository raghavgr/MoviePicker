//: Playground - noun: a place where people can play

import UIKit
import SwiftyJSON
import Alamofire
// NOTE: Uncommment following two lines for use in a Playground
 import XCPlayground
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
var str = "Hello, playground"
let url = NSBundle.mainBundle().URLForResource("data", withExtension: "json")
let data = NSData(contentsOfURL: url!)

do {
    let object = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)

} catch {
    // Handle Error
}

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