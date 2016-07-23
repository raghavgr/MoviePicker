//
//  ClarifaiClient.swift
//  MoviePicker
//
//  Created by Sai Grandhi on 7/15/16.
//  Copyright © 2016 Sai Grandhi. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class ClarifaiClient {
    
    var appID: String
    var appSecret: String
    var accessToken: String?
    var accessTokenExpiration: NSDate?
    
    init(appClarifaiID: String, appClarifaiSecret: String) {
        self.appID = appClarifaiID
        self.appSecret = appClarifaiSecret
        self.getAccessToken()
    }
    
    private func checkAccessToken(completionHandlerForAccessToken: (errorString: NSError?) -> ()) {
        if self.accessToken != nil && self.accessTokenExpiration != nil && self.accessTokenExpiration?.timeIntervalSinceNow > Config.MinimumTokenTime {
            completionHandlerForAccessToken(errorString: nil)
        } else {
            let urlParams: Dictionary<String, AnyObject> =
                [ "grant_type": "client_credentials",
                  "client_id": self.appID,
                  "client_secret": self.appSecret
                ]
            Alamofire.request(.POST, Config.APIBaseURL.stringByAppendingString("/token"), parameters: urlParams)
                .validate()
                .responseJSON() {
                    response in
                    switch response.result {
                    case .Success(let result):
                        let tokenResult = responseForToken(jsonResponse: result as! NSDictionary)
                        self.saveCurrentToken(tokenResult)
                        print("Validation Successful. Got access token")
                    case .Failure(let errorString):
                        completionHandlerForAccessToken(errorString: errorString)
                    }
                    
            }
        }
    }
    
    private func saveCurrentToken(result: responseForToken) {
        if let token = result.token, expiryTime = result.lastingTime {
            let defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
            let expiration: NSDate = NSDate(timeIntervalSinceNow: expiryTime)
            
            defaults.setValue(self.appID, forKey: Config.clientID)
            defaults.setValue(token, forKey: Config.AccessToken)
            defaults.setValue(expiration, forKey: Config.AccessTokenExpiryTime)
            defaults.synchronize()
            
            self.accessToken = token
            self.accessTokenExpiration = expiration
        }
    }
    
    private func cancelAccessToken() {
        let defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        defaults.removeObjectForKey(Config.clientID)
        defaults.removeObjectForKey(Config.AccessToken)
        defaults.removeObjectForKey(Config.AccessTokenExpiryTime)
        defaults.synchronize()
        
        self.accessToken = nil
        self.accessTokenExpiration = nil
    }
    
    private func getAccessToken() {
        let defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        
        if self.appID != defaults.stringForKey(Config.clientID){
            self.cancelAccessToken()
        } else {
            self.accessToken = defaults.stringForKey(Config.AccessToken)!
            self.accessTokenExpiration = defaults.objectForKey(Config.AccessTokenExpiryTime)! as? NSDate
        }
    }
    private class responseForToken: NSObject {
        var token: String?
        var lastingTime: NSTimeInterval?
        
        init(jsonResponse: NSDictionary) {
            self.token = jsonResponse["access_token"] as? String
            self.lastingTime = max(jsonResponse["expires_in"] as! Double, Config.MinimumTokenTime)
        }
    }
    
    // MARK : Processing Image
    
    private func recognizeImage(data: UIImage, completionHandlerForRecognizeImage: (recognizeResponse: clarifaiResponse?, ErrorType: NSError?) -> ()) {
        self.checkAccessToken() {
            (error) in
            // check if token is valid
            if error != nil {
                return completionHandlerForRecognizeImage(recognizeResponse: nil, ErrorType: error)
            }
            let endpointForTag = "/tag"
            Alamofire.upload(.POST, Config.APIBaseURL.stringByAppendingString(endpointForTag),
                headers: ["Authorization": "Bearer \(self.accessToken!)"],
                multipartFormData: {
                    multiPartFormData in
                    let size = CGSizeMake(320, 320 * data.size.height/data.size.width)
                    UIGraphicsBeginImageContext(size)
                    data.drawInRect(CGRectMake(0, 0, size.width, size.height))
                    let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
                    UIGraphicsEndImageContext()
                    
                    multiPartFormData.appendBodyPart(data: UIImageJPEGRepresentation(resizedImage, 0.9)!, name: "encoded_image", fileName: "image.jpg", mimeType: "image/jpeg")

                },
                encodingCompletion: {
                    encodingResult in
                    switch encodingResult {
                    case .Success(let upload, _, _):
                        upload.validate().responseJSON {
                            response in
                            switch response.result {
                            case .Success(let result):
                                let resultJSON = JSON(result)
                                let finalResult = clarifaiResponse(dict: resultJSON)
                                completionHandlerForRecognizeImage(recognizeResponse: finalResult, ErrorType: nil)
                            case .Failure(let error):
                                completionHandlerForRecognizeImage(recognizeResponse: nil, ErrorType: error)
                            }
                        }
                    case .Failure(let errorWhileEncoding):
                        print(errorWhileEncoding)
                    }
                }
            )
        }
        
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
 /**
    // MARK: Helper functions
    // given raw JSON, return a usable Foundation object
    class func convertDataWithCompletionHandler(data: NSData, completionHandlerForConvertData: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsedResult: AnyObject!
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(result: nil, error: NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandlerForConvertData(result: parsedResult, error: nil)
    }
    
    // Escape HTML Parameters
    class func createURLWithParameters(params: [String : AnyObject]) -> String {
        
        var urlAdditions = [String]()
        
        for (key, val) in params {
            
            /* query result */
            let stringResult = "\(val)"
            
            /* encode it */
            let encodedValue = stringResult.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlAdditions += [key + "=" + "\(encodedValue!)"]
            
        }
        
        return (!urlAdditions.isEmpty ? "?" : "") + urlAdditions.joinWithSeparator("&")
    } 
     */
}