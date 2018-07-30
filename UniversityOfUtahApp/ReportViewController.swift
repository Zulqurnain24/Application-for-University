
//  Created by Mohammad Zulqurnain on 23/08/2016.
//  Copyright © 2016 Mohammad Zulqurnain. All rights reserved.
//

import UIKit
import Foundation
import CoreData

class ReportViewController: UIViewController, NSFetchedResultsControllerDelegate {
    //variables
    //variables
    var fontSize = CGFloat(12)
    var fontNameString = String("AppleSDGothicNeo-Bold")
    var registrationContentData  = [JSON]()
    var userID = NSString()
    var portalID = NSString()
    var classID = NSString()
    var monthType = NSString()
    
    
    var managedObjectContext: NSManagedObjectContext!
    var fetchedResultsController: NSFetchedResultsController<ReportEntity>!
    var reportPredicate: NSPredicate?
    
    
    //interface
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var cellNameValueLabel: UILabel!
    @IBOutlet weak var phoneNameValueLabel: UILabel!
    @IBOutlet weak var lastNameValueLabel: UILabel!
    @IBOutlet weak var firstNameValueLabel: UILabel!
    @IBOutlet weak var parentNameValueLabel: UILabel!
    @IBOutlet weak var emailValueLabel: UILabel!
    @IBOutlet weak var firstNameKeyLabel: UILabel!
    @IBOutlet weak var lastNameKeyLabel: UILabel!
    @IBOutlet weak var emailKeyLabel: UILabel!
    @IBOutlet weak var parentNameKeyLabel: UILabel!
    @IBOutlet weak var cellNameKeyLabel: UILabel!
    @IBOutlet weak var phoneNameKeyLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        fontSize = appDelegate.fontSize
        fontNameString = appDelegate.fontNameString
        
        cellNameValueLabel.font = UIFont(name: fontNameString!, size: fontSize)
        phoneNameValueLabel.font = UIFont(name: fontNameString!, size: fontSize)
        lastNameValueLabel.font = UIFont(name: fontNameString!, size: fontSize)
        firstNameValueLabel.font = UIFont(name: fontNameString!, size: fontSize)
        parentNameValueLabel.font = UIFont(name: fontNameString!, size: fontSize)
        emailValueLabel.font = UIFont(name: fontNameString!, size: fontSize)
        
        firstNameKeyLabel.font = UIFont(name: fontNameString!, size: fontSize)
        
        lastNameKeyLabel.font = UIFont(name: fontNameString!, size: fontSize)
        
        emailKeyLabel.font = UIFont(name: fontNameString!, size: fontSize)
        parentNameKeyLabel.font = UIFont(name: fontNameString!, size: fontSize)
        cellNameKeyLabel.font = UIFont(name: fontNameString!, size: fontSize)
        phoneNameKeyLabel.font = UIFont(name: fontNameString!, size: fontSize)
        
        activityIndicator.center.x = self.view.center.x
        
        activityIndicator.setNeedsDisplay()
        
        print("monthType:\(monthType) classID : \(classID) userID : \(userID) portalID : \(portalID)")
        
        //post request
//        self.postRequest(["intMonthType":"\(monthType)","intClassID":"\(classID)","intUserId":"\(userID)","intPortalID":"\(portalID)"], url: "http://rest.coachmore.com/CoachesRoster/GetUsersCoachesRoster") { (succeeded: Bool, msg: String) -> () in
//            
//        }

        startCoreData()
        
        self.reportPredicate = nil
        
        print("firstTime \(appDelegate.firstTime)")
        
        
        if(IJReachability.isConnectedToNetwork()){
            
            //self.loadSavedData()
            loadSavedData()
            performSelector(inBackground: #selector(fetchCommits), with: nil)
            
        }else if(!appDelegate.firstTime){
            
            loadSavedData()
            
        }else{
            
            let createAccountErrorAlert: UIAlertView = UIAlertView()
            createAccountErrorAlert.delegate = self
            createAccountErrorAlert.title = "Error"
            createAccountErrorAlert.message = "Please Connect to internet."
            createAccountErrorAlert.addButton(withTitle: "Proceed")
            createAccountErrorAlert.show()
            
            
        }
    }
    
    
    
    // this is our usual helper function to find the user's documents directory
    func getDocumentsDirectory() -> URL {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[0]
    }
    
    func saveContext() {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                print("An error occurred while saving: \(error)")
            }
        }
    }
    
    func loadSavedData() {
        if fetchedResultsController == nil {
            let fetch: NSFetchRequest<NSFetchRequestResult>
                = NSFetchRequest(entityName: "ReportEntity")
            //let sort1 = NSSortDescriptor(key: "lastname", ascending: true)
            //let sort2 = NSSortDescriptor(key: "RosterEntityfirstname", ascending: true)
            fetch.sortDescriptors = []
            fetch.fetchBatchSize = 20
            
            fetchedResultsController = NSFetchedResultsController(fetchRequest: fetch as! NSFetchRequest<ReportEntity>, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
            fetchedResultsController.delegate = self
        }
        
        fetchedResultsController.fetchRequest.predicate = reportPredicate
        
        do {
            try fetchedResultsController.performFetch()
            //update UI in main thread once the loading is completed.
            self.activityIndicator.stopAnimating()
            populateForm()
        } catch {
            print("Fetch failed")
            let createAccountErrorAlert: UIAlertView = UIAlertView()
            createAccountErrorAlert.delegate = self
            createAccountErrorAlert.title = "Error"
            createAccountErrorAlert.message = "Cannot load data from memory."
            createAccountErrorAlert.addButton(withTitle: "Proceed")
            createAccountErrorAlert.show()
        }
    }
    
    
    
    func configureReportEntity(_ reportEntity: ReportEntity, usingJSON json: JSON) {
        
        if json["LastName"].stringValue != nil{
            reportEntity.lastname = json["LastName"].stringValue as String
            //print("firstname :  \(rosterEntity.firstname)")
        }else{
            reportEntity.lastname = "Nil"
        }
        
        if json["FirstName"].stringValue != nil{
            reportEntity.firstname = json["FirstName"].stringValue as String
            //print("lastname :  \(rosterEntity.lastname)")
        }else{
            reportEntity.firstname = "Nil"
        }
        
        if json["Phone"].stringValue != nil{
            reportEntity.phonenumber = json["Phone"].stringValue as String
            //print("firstname :  \(rosterEntity.firstname)")
        }else{
            reportEntity.phonenumber = "Nil"
        }
        
        if json["Cell"].stringValue != nil{
            reportEntity.mobilenumber = json["Cell"].stringValue as String
            //print("phonenumber :  \(rosterEntity.phonenumber)")
        }else{
            reportEntity.mobilenumber = "Nil"
        }
        
        
    }
    
    
    
    func fetchCommits() {
        
        //post request

        self.postRequest(["intMonthType":"\(monthType)","intClassID":"\(classID)","intUserId":"\(userID)","intPortalID":"\(portalID)"], url: "http://rest.coachmore.com/CoachesRoster/GetUsersCoachesRoster") { (succeeded: Bool, msg: String) -> () in

        }
    }
    
    func startCoreData() {
        // 1
        let modelURL = Bundle.main.url(forResource: "UniversityOfUtahApp", withExtension: "momd")!
        let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL)!
        
        // 2
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        
        // 3
        let url = getDocumentsDirectory().appendingPathComponent("SingleViewCoreData.sqlite")
        
        do {
            // 4
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true])
            
            // 5
            managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            managedObjectContext.persistentStoreCoordinator = coordinator
            managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        } catch {
            print("Failed to initialize the application's saved data")
            return
        }
    }

    func convertDateFormater(_ date: String) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        let date = dateFormatter.date(from: date)
        let calendar = Calendar.current
        let comp = (calendar as NSCalendar).components([.hour, .minute], from: date!)
        let hour = comp.hour
        let minute = comp.minute
        let second = comp.second
        return "\(hour) : \(minute) : \(second) "
    }
    
    func populateForm()
    {
        let object = NSEntityDescription.insertNewObject(forEntityName: "ReportEntity", into: self.managedObjectContext) as? ReportEntity
        
        print("reportview-i am in populateForm")
        if !object!.mobilenumber.isEmpty
        {
        cellNameValueLabel.text = object!.mobilenumber
        }
        if !object!.phonenumber.isEmpty
        {
        phoneNameValueLabel.text = object!.phonenumber
        }
        if !object!.lastname.isEmpty
        {
        lastNameValueLabel.text = object!.lastname
        }
        if !object!.firstname.isEmpty
        {
        firstNameValueLabel.text = object!.firstname
        }
        if !object!.parentname.isEmpty
        {
        parentNameValueLabel.text = object!.parentname
        }
        if !object!.emailaddress.isEmpty
        {
        emailValueLabel.text = object!.emailaddress
        }

        
        self.view.setNeedsDisplay()
    }
    
    func postRequest(_ params : Dictionary<String, String>, url : String, postCompleted : @escaping (_ succeeded: Bool, _ msg: String) -> ()) {
        
        
        if IJReachability.isConnectedToNetwork(){
            
            self.activityIndicator.startAnimating()
            
            let request = NSMutableURLRequest(url: URL(string: url)!)
            let session = URLSession.shared
            request.httpMethod = "POST"
            
            var err: NSError?
            do {
                request.httpBody = try!JSONSerialization.data(withJSONObject: params, options: [])
            } catch let error as NSError {
                err = error
                print("JSON parse error: \(err)")
                request.httpBody = nil
            }
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")

            
            let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
                
                // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
                if(error != nil) {
                    //println(err!.localizedDescription)
                    let jsonStr = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                    print("Error could not parse JSON: '\(jsonStr)'")
                    postCompleted(false, "Error")
                }
                else {
                    
                    let json = try!JSONSerialization.jsonObject(with: data!, options: .mutableLeaves) as? JSON
                    
                    // The JSONObjectWithData constructor didn't return an error. But, we should still
                    // check and make sure that json has a value using optional binding.
                    if let parseJSON = json {
                        // Okay, the parsedJSON is here, let's get the value for 'success' out of it
                        if let success = parseJSON["success"] as? Bool {
                            print("Succes: \(success)")
                            postCompleted(success, "Successfully posted.")
                        }


                        
                        return
                    }
                    else {
                        // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                        //let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                        //print("Error could not parse JSON: \(jsonStr)")
                        DispatchQueue.global( priority: DispatchQueue.GlobalQueuePriority.background).async(execute: {
                            //Load something here. Notice this is not main thread and you can't change anything in UI from here.
                            
                            //print("vote posted")
                            let datastring:NSString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!
                            //datastring = datastring.substringFromIndex(69)
                            let jsonData:Data = datastring.data(using: String.Encoding.utf8.rawValue)!
                            do {
                                let json = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as? JSON

                                //print("json array: \(json)")
                                
                                print("class json : \(json)")
                  
                                
                                
                                for element in 0...((json as AnyObject).count - 1){
                                    
                                    //print("element(username) : \(json[element]["username"])")
                                    self.registrationContentData.append(JSON(object: (json?[element])))
                                }
                                
                                for jsonCommit in self.registrationContentData {
                                    // the following three lines are new
                                    if let reportEntity = NSEntityDescription.insertNewObject(forEntityName: "ReportEntity", into: self.managedObjectContext) as? ReportEntity {
                                        self.configureReportEntity(reportEntity, usingJSON:jsonCommit )
                                    }
                                    
                                }
                                
                                self.saveContext()
                                self.loadSavedData()
                                
                                
                                DispatchQueue.main.async(execute: {
                                    //update UI in main thread once the loading is completed.
                                    self.activityIndicator.stopAnimating()
                                    if(self.registrationContentData.count > 0){
                                        self.populateForm()
                                    }
                                    
                                });
                                
                            } catch {
                                print("error serializing JSON: \(error)")
                            }
                            
                            
                        })
                        postCompleted(false, "Error")
                 
                    }
                }
            })
            
            task.resume()
        }else {
            self.activityIndicator.stopAnimating()
            let createAccountErrorAlert: UIAlertView = UIAlertView()
            createAccountErrorAlert.delegate = self
            createAccountErrorAlert.title = "Error"
            createAccountErrorAlert.message = "Please Connect to internet."
            createAccountErrorAlert.addButton(withTitle: "Proceed")
            createAccountErrorAlert.show()
            
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
