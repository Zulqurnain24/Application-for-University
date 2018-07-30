//
//  LoginView.swift
//  UniversityOfUtahApp
//
//  Created by Mohammad Zulqurnain on 24/08/2016.
//  Copyright © 2016 Mohammad Zulqurnain. All rights reserved.
//

//  Created by Mohammad Zulqurnain on 23/08/2016.
//  Copyright © 2016 Mohammad Zulqurnain. All rights reserved.
//

import UIKit
import Foundation

class LoginViewController: UIViewController  {
    
    //user interfaces
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var rememberPasswordToggle: UISwitch!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    
    //variables
    var fontSize = CGFloat(12)
    var fontNameString:String = String("AppleSDGothicNeo-Bold")
    var uID:String = String()
    var portalID:String = String()

    //animation holder
    var holderView = HolderView(frame: CGRect.zero)
    
    
    override func viewWillLayoutSubviews() {
       loginButton.isEnabled = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // Do any additional setup after loading the view, typically from a nib.
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        fontSize = appDelegate.fontSize
        fontNameString = appDelegate.fontNameString!
        
        let userDefault = UserDefaults.standard
        
        if userDefault.object(forKey: "userName") != nil{
            userNameTextField.text = userDefault.string(forKey: "userName")! as String
            passwordTextField.text = userDefault.string(forKey: "password")! as String
            rememberPasswordToggle.isOn = userDefault.bool(forKey: "isLogin") as Bool
        }
        loginButton.isEnabled = true
       
        if rememberPasswordToggle.isOn{
            
            loginButton.isEnabled = false
            activityIndicator.isHidden = false
            print("userNameTextField : \(userNameTextField.text! as String)")
            
            self.getRequest("portalID", params: ["":""], url: "http://rest.coachmore.com/DnnUser/GetPortalIdByUsername/\(userNameTextField.text! as String)") { (succeeded: Bool, msg: String) -> () in
                
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
       super.viewDidAppear(animated)
       activityIndicator.isHidden = true
    }
    
    
    //toggle password action
    @IBAction func toggleRememberPasswordAction(_ sender: AnyObject) {
      //rememberPasswordToggle.on = !rememberPasswordToggle.on
    }

    //New
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //print("i am in prepareForSegue")
        
        DispatchQueue.global( priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
            if segue.identifier! == "roasterSegueIdentifier" && !(self.userNameTextField.text!.isEmpty) {
                
                if let destination = segue.destination as? RoasterViewController {
                   destination.userPassword = NSString(string: self.passwordTextField.text!)
                   destination.userID = self.uID
                   destination.portalID  = self.portalID
                   print("segue.identifier == roasterSegueIdentifier ")

                    
                    DispatchQueue.main.async(execute: {
                    let userDefault = UserDefaults.standard
                    userDefault.set(self.userNameTextField.text, forKey: "userName")
                    userDefault.set(self.passwordTextField.text, forKey: "password")
                    userDefault.set(self.rememberPasswordToggle.isOn, forKey: "isLogin")
                        
                    userDefault.synchronize()


                    })
                    
                }
            }else{
                let createAccountErrorAlert: UIAlertView = UIAlertView()
                createAccountErrorAlert.delegate = self
                createAccountErrorAlert.title = "Error"
                createAccountErrorAlert.message = "Please Fill in the user name."
                createAccountErrorAlert.addButton(withTitle: "Proceed")
                createAccountErrorAlert.show()
            }
        })
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
       
        if identifier == "roasterSegueIdentifier"{
            //print("segue.identifier == self.postviewidentifier ")
           if ((self.userNameTextField.text?.isEmpty) == true)
           {
            return false
           }
        }
        return true

    }

    override func viewWillAppear(_ animated: Bool) {
        
        //activityIndicator.stopAnimating()
        
    }

    //code for get request
    func getRequest(_ type:String, params : Dictionary<String, String>, url : String, postCompleted : (_ succeeded: Bool, _ msg: String) -> ()) {
        
        
        if IJReachability.isConnectedToNetwork(){
            
            let request = NSMutableURLRequest(url: URL(string: url)!)
            let session = URLSession.shared
            request.httpMethod = "GET"
            
            let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
                
                
                let datastring:NSString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!

                let jsonData:Data = datastring.data(using: String.Encoding.utf8.rawValue)!
                do {
                    let json = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as? JSON
                    
                    if type == "portalID"{
                        //print("element(username) : \(json[element]["username"])")
                        self.portalID = NSString(string: JSON(object: (json?[0])).stringValue) as String
                        print("portalIDString : \(self.portalID as NSString)")
                        self.getRequest("uuid", params: ["":""], url: "http://learntodive.org/WCFLoginService.aspx?portalId=\(self.portalID as String)&userName=\(self.userNameTextField.text! as  String)&password=\( self.passwordTextField.text! as String)") { (succeeded: Bool, msg: String) -> () in
                            
                        }
                       
                    }else if type == "uuid"{
                        //if
                        let userId = (json?["UserId"].int)
                        //{
                        print("json: \( userId)")

                        self.uID  = "\(userId)"
                        //print("self.uID : \(self.uID)")

                        DispatchQueue.main.async(execute: {
                            //update UI in main thread once the loading is completed.
                            //self.activityIndicator.stopAnimating()

                            self.performSegue(withIdentifier: "roasterSegueIdentifier", sender: nil)

                        });
                      }
                   // }
                    
                } catch {
                    print("error serializing JSON: \(error)")
                }
            })
            
            task.resume()
        }else {
            
            let createAccountErrorAlert: UIAlertView = UIAlertView()
            createAccountErrorAlert.delegate = self
            createAccountErrorAlert.title = "Error"
            createAccountErrorAlert.message = "Please Connect to internet."
            createAccountErrorAlert.addButton(withTitle: "Proceed")
            createAccountErrorAlert.show()
            
        }
    }

   
    override func viewWillDisappear(_ animated: Bool) {
    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loadApiAndGoToRoasterViewAction(_ sender: AnyObject) {
        
        loginButton.isEnabled = false
        activityIndicator.isHidden = false
        print("userNameTextField : \(userNameTextField.text! as String)")
        
        self.getRequest("portalID", params: ["":""], url: "http://rest.coachmore.com/DnnUser/GetPortalIdByUsername/\(userNameTextField.text! as String)") { (succeeded: Bool, msg: String) -> () in
            
        }
        
    }
    
}
