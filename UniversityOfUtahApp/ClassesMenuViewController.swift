
//  Created by Mohammad Zulqurnain on 23/08/2016.
//  Copyright © 2016 Mohammad Zulqurnain. All rights reserved.
//


import UIKit
import Foundation
import CoreData

class ClassesMenuViewController: UIViewController, UIPickerViewDelegate, NSFetchedResultsControllerDelegate {

    //variables
    var fontSize = CGFloat(12)
    var fontNameString = String("AppleSDGothicNeo-Bold")
    var arrayForClasses = [String]()
    var ClassDropDownListData  = [JSON]()
    var managedObjectContext: NSManagedObjectContext!
    var fetchedResultsController: NSFetchedResultsController<ClassMenuEntity>!
    var classMenuPredicate: NSPredicate?
    var userID = NSString()
    var portalID = NSString()
    var classID = NSString()
    var categoryOption = Int()
    @IBOutlet weak var segmentControlForMonthCategory: UISegmentedControl!
    @IBOutlet weak var labelForLocationKeyValue: UILabel!
    @IBOutlet weak var labelForGroupKeyValue: UILabel!
    @IBOutlet weak var labelForDayOfWeekKeyValue: UILabel!
    @IBOutlet weak var labelForStartingTimeKeyValue: UILabel!
    @IBOutlet weak var labelForLocationValue: UILabel!
    @IBOutlet weak var labelForGroupValue: UILabel!
    @IBOutlet weak var labelForStartingTimeValue: UILabel!
    @IBOutlet weak var buttonForViewReport: UIButton!
    @IBOutlet weak var pickerForClassesName: UIPickerView!
    @IBOutlet weak var labelForDayOfWeekValue: UILabel!
    @IBOutlet weak var activityIndicatorControl: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationController?.title = "Class Drop Down Menu"

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        fontSize = appDelegate.fontSize
        fontNameString = appDelegate.fontNameString
        
        segmentControlForMonthCategory.layer.cornerRadius = 5.0
        buttonForViewReport.layer.cornerRadius = 5.0
        labelForLocationKeyValue.font = UIFont(name: fontNameString!, size: fontSize)
        labelForGroupKeyValue.font = UIFont(name: fontNameString!, size: fontSize)
        labelForDayOfWeekKeyValue.font = UIFont(name: fontNameString!, size: fontSize)
        labelForStartingTimeKeyValue.font = UIFont(name: fontNameString!, size: fontSize)
        
        labelForLocationValue.font = UIFont(name: fontNameString!, size: fontSize)
        labelForGroupValue.font = UIFont(name: fontNameString!, size: fontSize)
        labelForDayOfWeekValue.font = UIFont(name: fontNameString!, size: fontSize)
        labelForStartingTimeValue.font = UIFont(name: fontNameString!, size: fontSize)
        
        print("ClassesMenuViewController - viewDidLoad")
        
        
        if(self.segmentControlForMonthCategory.selectedSegmentIndex == 0)
        {
            self.categoryOption = 1
        }
        else
        {
            self.categoryOption = 2
        }
        
        pickerForClassesName.delegate = self
        
        //set default values
       // categoryOption = 1
        classID = NSString(string: "0")
        
        //post request
//        self.postRequest(["intUserId":"\(userID)","intPortalID":"\(portalID)"], url: "http://rest.coachmore.com/CoachesRoster/GetUsersClassList") { (succeeded: Bool, msg: String) -> () in
//            
//        }
//      
        
        startCoreData()
        
        self.classMenuPredicate = nil
        
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
        //performSelectorInBackground(#selector(fetchCommits), withObject: nil)
        

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
            //let fetch = NSFetchRequest(entityName: "ClassMenuEntity")
            let fetch: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "ClassMenuEntity")
            //let sort1 = NSSortDescriptor(key: "lastname", ascending: true)
            //let sort2 = NSSortDescriptor(key: "RosterEntityfirstname", ascending: true)
            fetch.sortDescriptors = []
            fetch.fetchBatchSize = 20
            
            fetchedResultsController = NSFetchedResultsController(fetchRequest: fetch as! NSFetchRequest<ClassMenuEntity>, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
            fetchedResultsController.delegate = self
        }
        
        fetchedResultsController.fetchRequest.predicate = classMenuPredicate
        
        do {
            try fetchedResultsController.performFetch()
            //update UI in main thread once the loading is completed.
            self.activityIndicatorControl.stopAnimating()
            self.populateForm()
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

    
    
    func configureClassMenuEntity(_ classMenuEntity: ClassMenuEntity, usingJSON json: JSON) {
        
         print("json : \(json)")
        
        if json["Location"].stringValue != nil{
            classMenuEntity.location = json["Location"].stringValue as String
            //print("firstname :  \(rosterEntity.firstname)")
        }else{
            classMenuEntity.location = "Nil"
        }
        
        if json["Group"].stringValue != nil{
            classMenuEntity.group = json["Group"].stringValue as String
            //print("lastname :  \(rosterEntity.lastname)")
        }else{
            classMenuEntity.group = "Nil"
        }
        
        if json["DayOfWeek"].stringValue != nil{
            classMenuEntity.dayofweek = json["DayOfWeek"].stringValue as String
            //print("firstname :  \(rosterEntity.firstname)")
        }else{
            classMenuEntity.dayofweek = "Nil"
        }
        
        if json["StartTime"].stringValue != nil{
            classMenuEntity.starttime = json["StartTime"].stringValue as String
            //print("phonenumber :  \(rosterEntity.phonenumber)")
        }else{
            classMenuEntity.starttime = "Nil"
        }
        
        if json["Description"].arrayValue != nil{
            var classesArray = [String]()
            for element in json["Description"].arrayValue{
            let stringElement = element.stringValue as String
            classesArray.append( stringElement )
            }
            classMenuEntity.descriptiondetail = classesArray as NSArray
            //print("cellnumber :  \(rosterEntity.cellnumber)")
        }else{
            
            var classesArray = [String]()
            classesArray.append( "No class information" )
            classMenuEntity.descriptiondetail = classesArray as NSArray
//            classMenuEntity.descriptiondetail.count >  = "Nil"
        }
        
    }
    

    
    func fetchCommits() {
        
        self.postRequest(["intUserId":"\(userID)","intPortalID":"\(portalID)"], url: "http://rest.coachmore.com/CoachesRoster/GetUsersClassList") { (succeeded: Bool, msg: String) -> () in
            
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
    

    
    @IBAction func selectSegmentAction(_ sender: AnyObject) {
        
        if(self.segmentControlForMonthCategory.selectedSegmentIndex == 0)
        {
            self.categoryOption = 1
        }
        else
        {
            self.categoryOption = 2
        }
        
        //post request
        loadSavedData()
        fetchCommits()
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
        let object = NSEntityDescription.insertNewObject(forEntityName: "ClassMenuEntity", into: self.managedObjectContext) as? ClassMenuEntity

        print("ClassMenuEntity - i am in populateForm")
        if let locationString:String = object!.location
        {
            labelForLocationValue.text = locationString
        }
        if let groupString:String = object!.group
        {
            labelForLocationValue.text = groupString
        }
        if let dayofweekString:String = object!.dayofweek
        {
            labelForLocationValue.text = dayofweekString
        }
         if let dayStarttime:String = object!.starttime
        {
           labelForStartingTimeValue.text = dayStarttime
            
        }
         if let descriptiondetail:[String] = object!.descriptiondetail as? [String]
        {

            for element in descriptiondetail {
                
            arrayForClasses.append( element )
                
            }
            pickerForClassesName.setNeedsDisplay()
        }
       
        self.view.setNeedsDisplay()
    }

    func numberOfComponentsInPickerView(_ pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        print("Count: \(ClassDropDownListData.count) ")
        return ClassDropDownListData.count
        
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
     
        if ClassDropDownListData.count > 0{
        return arrayForClasses[row]
        }else{
        return "No class data to show"
        }

    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row < 0{
        classID = "\(0)" as NSString
        }else{
        classID = "\(row)" as NSString
        }
    }
    
 
    func postRequest(_ params : Dictionary<String, String>, url : String, postCompleted : @escaping (_ succeeded: Bool, _ msg: String) -> ()) {
        
        
        if IJReachability.isConnectedToNetwork(){
            
            self.activityIndicatorControl.startAnimating()
            
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
            
            //

            //let task = URLSession.shared.dataTask(with: request, completionHandler: {data, response, error -> Void in
                
            
            let task = URLSession.shared.dataTask(with: request  as URLRequest, completionHandler: {data, response, error -> Void in
                
                // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
                if(error != nil) {
                    //println(err!.localizedDescription)
                    let jsonStr = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                    print("Error could not parse JSON: '\(jsonStr)'")
                    postCompleted(false, "Error")
                }
                else {
                    
                    let json = try!JSONSerialization.jsonObject(with: data!, options: .mutableLeaves) as? NSDictionary
                    
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
                        postCompleted(false, "Error")
                        DispatchQueue.global( priority: DispatchQueue.GlobalQueuePriority.background).async(execute: {
                            //Load something here. Notice this is not main thread and you can't change anything in UI from here.
                            
                            //print("vote posted")
                            let datastring:NSString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!
                            //datastring = datastring.substringFromIndex(69)
                            let jsonData:Data = datastring.data(using: String.Encoding.utf8.rawValue)!
                            do {
                                let json = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as? JSON
                                print("json?.count: \(json?.count)")
                                if json != nil {
                                
                                for element in 0...((json as AnyObject).count - 1){
                                    
                                    //print("element(username) : \(json[element].stringValue)")
                                    self.ClassDropDownListData.append(JSON(object: (json?[element])))
                                }

                                if self.ClassDropDownListData.count > 0 {

                                    print("Received \(self.ClassDropDownListData.count) new commits.")
                                    //            self.tableView.reloadData()
                                    //            self.view.setNeedsDisplay()
                                    
                                    DispatchQueue.main.async { [unowned self] in
                                        for jsonCommit in self.ClassDropDownListData {
                                            // the following three lines are new
                                            if let classEntity = NSEntityDescription.insertNewObject(forEntityName: "ClassMenuEntity", into: self.managedObjectContext) as? ClassMenuEntity {
                                                self.configureClassMenuEntity(classEntity, usingJSON:jsonCommit )
                                            }
                                            
                                        }
                                        
                                        self.saveContext()
                                        self.loadSavedData()
                                        //update UI in main thread once the loading is completed.
                                        self.activityIndicatorControl.stopAnimating()
                                        if(self.ClassDropDownListData.count > 0){
                                            self.populateForm()
                                        }
                                        self.activityIndicatorControl.stopAnimating()
                                    }
                                    
                                }
                                }
                                
                            } catch {
                                print("error serializing JSON: \(error)")
                            }
                            
                            
                        })
                        
                    }
                }
            })
            
            task.resume()
        }else {
            self.activityIndicatorControl.stopAnimating()
            let createAccountErrorAlert: UIAlertView = UIAlertView()
            createAccountErrorAlert.delegate = self
            createAccountErrorAlert.title = "Error"
            createAccountErrorAlert.message = "Please Connect to internet."
            createAccountErrorAlert.addButton(withTitle: "Proceed")
            createAccountErrorAlert.show()
            
        }
    }
    
    //New
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
        if segue.identifier! == "reportViewIdentifier" {
            
            if let destination = segue.destination as? ReportViewController {
                destination.userID = NSString(string: "\(self.userID)")
                destination.portalID = NSString(string: "\(portalID)")
                destination.classID = NSString(string: "\(classID)")
                destination.monthType = NSString(string: "\(categoryOption)")
                print("segue.identifier == reportViewIdentifier ")
            }
        }else{
            let createAccountErrorAlert: UIAlertView = UIAlertView()
            createAccountErrorAlert.delegate = self
            createAccountErrorAlert.title = "Error"
            createAccountErrorAlert.message = "Please Fill in the user name."
            createAccountErrorAlert.addButton(withTitle: "Proceed")
            createAccountErrorAlert.show()
        }
        // })
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
