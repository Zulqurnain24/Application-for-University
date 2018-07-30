//
//  ViewController.swift
//  Swift Slide View
//
//  Created by Mohammad Zulqurnain on 13/08/16.
//

import Foundation

var  urlString:String = ""

class DataManager {

    class func getJsonAPIWithSuccess(_ success: @escaping ((_ apiData: Data?) -> Void)) {

        //1
        DataManager.loadDataFromURL(URL(string: "http://rest.coachmore.com\(urlString)")!, completion:{(data, error) -> Void in
        //2
        if let urlData = data {
          //3
          success(urlData)
        }
    })
  }

    class func loadDataFromURL(_ url: URL, completion:@escaping (_ data: Data?, _ error: NSError?) -> Void) {
    let session = URLSession.shared
    
    // Use NSURLSession to get data from an NSURL
    let loadDataTask = session.dataTask(with: url, completionHandler: { (data: Data?, response: URLResponse?, error: NSError?) -> Void in
      if let responseError = error {
        completion(nil, responseError)
      } else if let httpResponse = response as? HTTPURLResponse {
        if httpResponse.statusCode != 200 {
          let statusError = NSError(domain:"com.raywenderlich", code:httpResponse.statusCode, userInfo:[NSLocalizedDescriptionKey : "HTTP status code has unexpected value."])
          completion(nil, statusError)
        } else {
          completion(data, nil)
        }
      }
    } as! (Data?, URLResponse?, Error?) -> Void)
    
    loadDataTask.resume()
  }
}
