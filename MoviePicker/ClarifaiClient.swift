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
    var accessTokenExpiration: Date?
    
    init(appClarifaiID: String, appClarifaiSecret: String) {
        self.appID = appClarifaiID
        self.appSecret = appClarifaiSecret
        self.getAccessToken()
    }
    
    func checkAccessToken(_ completionHandlerForAccessToken: @escaping (_ errorString: NSError?) -> ()) {
        if self.accessToken != nil && self.accessTokenExpiration != nil && (self.accessTokenExpiration?.timeIntervalSinceNow)! > Config.MinimumTokenTime {
            completionHandlerForAccessToken(nil)
        } else {
            let urlParams: Dictionary<String, AnyObject> =
                [ "grant_type": "client_credentials" as AnyObject,
                  "client_id": self.appID as AnyObject,
                  "client_secret": self.appSecret as AnyObject
                ]
            Alamofire.request(Config.APIBaseURL.appending("/token"), method: .post, parameters: urlParams)
                .validate()
                .responseJSON() {
                    response in
                    switch response.result {
                    case .success(let result):
                        print("Validation Successful. Got access token")
                        let tokenResult = responseForToken(jsonResponse: result as! NSDictionary)
                        self.saveCurrentToken(tokenResult)
                        
                    case .failure(let errorString):
                        completionHandlerForAccessToken(errorString as NSError?)
                    }
                    
            }
        }
    }
    
    func saveCurrentToken(_ result: responseForToken) {
        if let token = result.token, let expiryTime = result.lastingTime {
            let defaults: UserDefaults = UserDefaults.standard
            let expiration: Date = Date(timeIntervalSinceNow: expiryTime)
            print("in save current token")
            defaults.setValue(self.appID, forKey: Config.clientID)
            defaults.setValue(result.token, forKey: Config.AccessToken)
            defaults.setValue(expiration, forKey: Config.AccessTokenExpiryTime)
            defaults.synchronize()
            
            self.accessToken = token
            self.accessTokenExpiration = expiration
            getAccessToken()
        }
    }
    
    func cancelAccessToken() {
        let defaults: UserDefaults = UserDefaults.standard
        defaults.removeObject(forKey: Config.clientID)
        defaults.removeObject(forKey: Config.AccessToken)
        defaults.removeObject(forKey: Config.AccessTokenExpiryTime)
        defaults.synchronize()
        
        self.accessToken = nil
        self.accessTokenExpiration = nil
    }
    
    func getAccessToken() {
        let defaults: UserDefaults = UserDefaults.standard
        print("in get access token")
        if self.appID != defaults.string(forKey: Config.clientID){
            
            self.checkAccessToken() {
                (error) in
                if error != nil {
                    print(error!)
                }
            }
        } else {
            self.accessToken = defaults.string(forKey: Config.AccessToken)!
            //print(self.accessToken!)
            self.accessTokenExpiration = defaults.object(forKey: Config.AccessTokenExpiryTime)! as? Date
        }
    }
    class responseForToken: NSObject {
        var token: String?
        var lastingTime: TimeInterval?
        
        init(jsonResponse: NSDictionary) {
            self.token = jsonResponse["access_token"] as? String
            self.lastingTime = max(jsonResponse["expires_in"] as! Double, Config.MinimumTokenTime)
        }
    }
    
    // MARK : Processing Image
    
    /// This method uploads the image for recognition
    /// Here are the steps you should follow to use this method
    ///
    /// 1. Prepare image to be sent
    ///
    /// 2. Call this method.
    ///
    /// Here are some bullet points to remember
    /// * Use Jpeg
    ///
    /// - parameters:
    ///   - int: An image `UIImage` parameter.
    /// - throws: throws an NSError
    /// - returns: a Clarifai Response.
    func recognizeImage(_ data: UIImage, completionHandlerForRecognizeImage: @escaping (_ recognizeResponse: clarifaiResponse?, _ ErrorType: NSError?) -> ()) {
        self.checkAccessToken() {
            (error) in
            // check if token is valid
            if error != nil {
                return completionHandlerForRecognizeImage(nil, error)
            }
            print("in recognizeImage")
            let endpointForTag = "/tag"
            let headers: HTTPHeaders = [
                "Authorization": "Bearer " + self.accessToken!,
                "Content-Type": "application/json"
            ]
            let tagURL = try! URLRequest(url: Config.APIBaseURL + endpointForTag, method: .post, headers: headers)
            Alamofire.upload(
                multipartFormData: {
                    multiPartFormData in
                    let size = CGSize(width: 320, height: 320 * data.size.height/data.size.width)
                    UIGraphicsBeginImageContext(size)
                    data.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
                    let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
                    UIGraphicsEndImageContext()
                    multiPartFormData.append(UIImageJPEGRepresentation(resizedImage!, 0.9)!, withName: "encoded_image", fileName: "image.jpg", mimeType: "image/jpeg")
                    print("in alamofire upload")
                },
                with: tagURL,
                encodingCompletion: {
                    encodingResult in
                    switch encodingResult {
                    case .success(let upload, _, _):
                        upload.responseJSON {
                            response in
                            switch response.result {
                            case .success(let result):
                                let resultJSON = JSON(result)
                                print("Image succesfully read")
                                let finalResult = clarifaiResponse(dict: resultJSON)
                                completionHandlerForRecognizeImage(finalResult, nil)
                            case .failure(let error):
                                completionHandlerForRecognizeImage(nil, error as NSError?)
                            }
                        }
                    case .failure(let errorWhileEncoding):
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
            print(statusMsg)
            print(statusCode)
            let allResults = dict["results"].arrayValue
            print("all results: \(allResults.count)")
            allTags = []
            for aResult in allResults {
                // tested all of this in playground
                let classes = aResult["result"]["tag"]["classes"].arrayObject
                let probabilities = aResult["result"]["tag"]["probs"].arrayObject
                let concepts = aResult["result"]["tag"]["concept_ids"].arrayObject
                print("in clarifaiResponse loop")
                for (i, classLabel) in classes!.enumerated() {
                    let probability = probabilities![i] as! Float
                    let concept = concepts![i]
                    print(classLabel)
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
