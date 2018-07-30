
//  Created by Mohammad Zulqurnain on 23/08/2016.
//  Copyright © 2016 Mohammad Zulqurnain. All rights reserved.
//

import UIKit
import Foundation
import CoreData

class RoasterViewController: UITableViewController, NSFetchedResultsControllerDelegate/*, HolderViewDelegate */{
    
    //user interface
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    //variables
   // var UserListData  = [JSON]()
    
    var managedObjectContext: NSManagedObjectContext!
    var fetchedResultsController: NSFetchedResultsController<RosterEntity>!
    var rosterPredicate: NSPredicate?
    
    var userID = String()
    var portalID = String()
    var userPassword = NSString()
    var index = Int()
    var fontSize = CGFloat(12)
    var fontNameString = String("AppleSDGothicNeo-Bold")
    
    //animation holder
    var holderView = HolderView(frame: CGRect.zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //activate activity indicator
         activityIndicator.isHidden = false
        
        // Do any additional setup after loading the view, typically from a nib.
        //print("i am in view did load!")
        //print("userID : \(self.userID)")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        fontSize = appDelegate.fontSize
        fontNameString = appDelegate.fontNameString
        activityIndicator.startAnimating()
        self.navigationController?.title = "User Rosters"
        
        self.activityIndicator.startAnimating()
        
         startCoreData()
        
        self.rosterPredicate = nil
        
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


    override func viewWillDisappear(_ animated: Bool) {

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
         appDelegate.firstTime = false
        //appDelegate.coreDataStack = coreDataStack
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
    
    func fetchCommits() {
        do{
            if let data:Data = try? Data(contentsOf: URL(string: "http://rest.coachmore.com/UserDirectory/GetUsersDirectory/\(self.userID)")!) {
                let jsonCommits = JSON(object: data as AnyObject)
                let jsonCommitArray = jsonCommits.arrayValue
                print("Received \(jsonCommitArray.count) new commits.")
    //            self.tableView.reloadData()
    //            self.view.setNeedsDisplay()
                
                DispatchQueue.main.async { [unowned self] in
                    for jsonCommit in jsonCommitArray {
                        // the following three lines are new
                        if let rosterEntity = NSEntityDescription.insertNewObject(forEntityName: "RosterEntity", into: self.managedObjectContext) as? RosterEntity {
                            self.configureRosterEntity(rosterEntity, usingJSON:jsonCommit )
                        }

                    }
                    
                    self.saveContext()
                    self.loadSavedData()
                    
                    self.tableView.reloadData()
                    self.activityIndicator.stopAnimating()
                }
       
            }
        }catch {
            print("error serializing JSON: \(error)")
        }

    }
    
    
    func configureRosterEntity(_ rosterEntity: RosterEntity, usingJSON json: JSON) {

        if json["firstname"].stringValue != nil{
        rosterEntity.firstname = json["firstname"].stringValue as String
        //print("firstname :  \(rosterEntity.firstname)")
        }else{
        rosterEntity.firstname = "Nil"
        }
        
        if json["lastname"].stringValue != nil{
        rosterEntity.lastname = json["lastname"].stringValue as String
        //print("lastname :  \(rosterEntity.lastname)")
        }else{
            rosterEntity.lastname = "Nil"
        }
        
        if json["Parent1"].stringValue != nil{
        rosterEntity.parentname = json["Parent1"].stringValue as String
        //print("firstname :  \(rosterEntity.firstname)")
        }else{
            rosterEntity.parentname = "Nil"
        }
        
        if json["Telephone"].stringValue != nil{
        rosterEntity.phonenumber = json["Telephone"].stringValue as String
        //print("phonenumber :  \(rosterEntity.phonenumber)")
        }else{
            rosterEntity.phonenumber = "Nil"
        }
        
        if json["Cell"].stringValue != nil{
        rosterEntity.cellnumber = json["Cell"].stringValue as String
        //print("cellnumber :  \(rosterEntity.cellnumber)")
        }else{
            rosterEntity.cellnumber = "Nil"
        }
        
        if json["email"].stringValue != nil{
        rosterEntity.email = json["email"].stringValue as String
        //print("email :  \(rosterEntity.email)")
        }else{
            rosterEntity.email = "Nil"
        }
    }
    
    func loadSavedData() {
        if fetchedResultsController == nil {
            let fetch: NSFetchRequest<NSFetchRequestResult>  = NSFetchRequest(entityName: "RosterEntity")
            //let sort1 = NSSortDescriptor(key: "lastname", ascending: true)
            //let sort2 = NSSortDescriptor(key: "RosterEntityfirstname", ascending: true)
            fetch.sortDescriptors = []
            fetch.fetchBatchSize = 20
            
            fetchedResultsController = NSFetchedResultsController(fetchRequest: fetch as! NSFetchRequest<RosterEntity>, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
            fetchedResultsController.delegate = self
        }
        
        fetchedResultsController.fetchRequest.predicate = rosterPredicate
        
        do {
            try fetchedResultsController.performFetch()
            //update UI in main thread once the loading is completed.
            self.activityIndicator.stopAnimating()
            self.tableView.reloadData()
            activityIndicator.isHidden = true
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

    
    /***************************Transition to class menu*********************************************************/
    
    //New
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
       // dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            if segue.identifier! == "classMenuIdentifier" {
                
                if let destination = segue.destination as? ClassesMenuViewController {
                    destination.userID = NSString(string: self.userID)
                    destination.portalID = NSString(string: self.portalID)
                    //print("segue.identifier == classMenuIdentifier ")
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
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        if identifier == "classMenuIdentifier"{
            ////print("segue.identifier == self.postviewidentifier ")
            if (!self.userID.isEmpty)
            {
                return true
            }
        }
        
        return false
        
    }

    /**************************************UITableViewControllerClasses******************************************/
//    func loadDataIntotableData()
//    {
//        //Animate activity indicator 
//        self.activityIndicator.startAnimating()
//
//        if IJReachability.isConnectedToNetwork() {
//
//            urlString = "/UserDirectory/GetUsersDirectory/\(userID)"
//
//            DataManager.getJsonAPIWithSuccess {(apiData) -> Void in
//                
//                let json = JSON(data: apiData)
//                
//                self.UserListData = json.arrayValue!
//                
//                dispatch_async(dispatch_get_main_queue(), {
//                    //update UI in main thread once the loading is completed.
//                    self.tableView.reloadData()
//                })
//            }
//            
//        } else {
//            //Load something here. Notice this is not main thread and you can't change anything in UI from here.
//            
//            dispatch_async(dispatch_get_main_queue(), {
//                //make and use a UIAlertView for network connection available
//                let createAccountErrorAlert: UIAlertView = UIAlertView()
//                createAccountErrorAlert.delegate = self
//                createAccountErrorAlert.title = "Error"
//                createAccountErrorAlert.message = "Please Connect to internet."
//                createAccountErrorAlert.addButtonWithTitle("Proceed")
//                createAccountErrorAlert.show()
//                
//                // Delay the dismissal by 5 seconds
//                let delay = 2.0 * Double(NSEC_PER_SEC)
//                let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
//                dispatch_after(time, dispatch_get_main_queue(), {
//                    createAccountErrorAlert.dismissWithClickedButtonIndex(-1, animated: true)
//                })
//                
//            })
//            
//        }
//        
//    }
//
    //UITableviewcell height adjust functions
    
    
    func heightForLabel(_ text:String, font:UIFont, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        
        label.sizeToFit()
        return label.frame.height
    }
    
    func heightForTextView(_ text:String, font:UIFont, width:CGFloat) -> CGFloat{
        let textView:UITextView = UITextView(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        textView.font = font
        textView.text = text
        textView.sizeToFit()
        return textView.frame.height
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }

    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return fetchedResultsController.sections![section].name
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let sectionInfo = fetchedResultsController.sections![(indexPath as NSIndexPath).section]

        if sectionInfo.numberOfObjects > 0{
            
        var descriptionLabelHeight = CGFloat(10.0)
        var locationLabelHeight = CGFloat(10.0)
        var groupLabelHeight = CGFloat(10.0)
        var dayOfWeekLabelHeight = CGFloat(10.0)
        var startTimeLabelHeight = CGFloat(10.0)
        var emailLabelHeight = CGFloat(10.0)
        let object = self.fetchedResultsController.object(at: indexPath) as! RosterEntity
            
            
            if !object.lastname.isEmpty
            {
                 descriptionLabelHeight = heightForTextView(object.lastname, font: UIFont (name: fontNameString!, size: fontSize)!, width: tableView.frame.width - 10)
            }
            if !object.firstname.isEmpty
            {
                 locationLabelHeight = heightForTextView(object.firstname, font: UIFont (name: fontNameString!, size: fontSize)!, width: tableView.frame.width - 10)
            }
            if !object.phonenumber.isEmpty
            {
                 groupLabelHeight = heightForTextView(object.phonenumber, font: UIFont (name: fontNameString!, size: fontSize)!, width: tableView.frame.width - 10)
            }
            if !object.cellnumber.isEmpty
            {
                 dayOfWeekLabelHeight = heightForTextView(object.cellnumber, font: UIFont (name: fontNameString!, size: fontSize)!, width: tableView.frame.width - 10)
            }
            if !object.parentname.isEmpty
            {
                 startTimeLabelHeight = heightForTextView(object.parentname, font: UIFont (name: fontNameString!, size: fontSize)!, width: tableView.frame.width - 10)
            }
            if !object.email.isEmpty
            {
                emailLabelHeight = heightForTextView(object.email, font: UIFont (name: fontNameString!, size: fontSize)!, width: tableView.frame.width - 10)
            }
            let totalHeightForRow = locationLabelHeight + groupLabelHeight + dayOfWeekLabelHeight + startTimeLabelHeight + descriptionLabelHeight + emailLabelHeight + 60
            //print("totalHeightForRow : \(totalHeightForRow)")
            return totalHeightForRow/*padding*/
        }
        
        return 10
        
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
         index = (indexPath as NSIndexPath).row
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //store index
        index = (indexPath as NSIndexPath).row
        
        //let appDelegate = UIApplication.sharedApplication().delegate as!AppDelegate
        let cell = tableView.dequeueReusableCell(withIdentifier: "userRoasterCell", for: indexPath) as! RoasterCell
        let object = self.fetchedResultsController.object(at: indexPath) as! RosterEntity
        
        
        //if(!UserListData.isEmpty)
        //{
            //let recordTapped = UserListData[indexPath.row]
            
            /*post start time date from string calculations*/
            if !object.firstname.isEmpty
            {
              cell.firstName.text =  object.firstname
            }
            if !object.lastname.isEmpty
            {
                cell.lastName.text = object.lastname
            }
            if !object.parentname.isEmpty
            {
                cell.parentName.text = object.parentname
            }
            if !object.phonenumber.isEmpty
            {
                cell.phoneNumber.text = object.phonenumber
            }
            if !object.cellnumber.isEmpty
            {
                cell.cellNumber.text = object.cellnumber
            }
            if !object.email.isEmpty
            {
                cell.emailAddress.text = object.email
            }
            return cell
      //  }
       // return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
      
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
