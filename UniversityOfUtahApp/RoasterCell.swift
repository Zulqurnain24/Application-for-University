//
//  RoasterCell.swift
//  classWave
//
//  Created by Mohammad Zulqurnain on 23/04/2015.
//  Copyright (c) 2015 Mohammad Zulqurnain. All rights reserved.
//
import UIKit
import Foundation

class RoasterCell: UITableViewCell, UITextViewDelegate{
    //variables
    var fontSize = CGFloat(12)
    var fontNameString = String("AppleSDGothicNeo-Bold")
    //UI items
    @IBOutlet weak var firstName: UILabel!
    @IBOutlet weak var lastName: UILabel!
    @IBOutlet weak var phoneNumber: UILabel!
    @IBOutlet weak var cellNumber: UILabel!
    @IBOutlet weak var parentName: UILabel!
    @IBOutlet weak var emailAddress: UILabel!
    
    @IBOutlet weak var firstNameLabel: UILabel!
    
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var cellNameLabel: UILabel!
    @IBOutlet weak var parentNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    override func awakeFromNib() {

        super.awakeFromNib()
       
        // Initialization code
        //font settings
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        fontSize = appDelegate.fontSize
        fontNameString = appDelegate.fontNameString
        //setting graphics attributes for Labels
        //key label
        firstNameLabel.font = UIFont(name: fontNameString!, size: fontSize)
        
        lastNameLabel.font = UIFont(name: fontNameString!, size: fontSize)
        
        parentNameLabel.font = UIFont(name: fontNameString!, size: fontSize)
        
        phoneLabel.font = UIFont(name: fontNameString!, size: fontSize)
        
        emailLabel.font = UIFont(name: fontNameString!, size: fontSize)
        
        cellNameLabel.font = UIFont(name: fontNameString!, size: fontSize)
        
        //value label
        firstName.font = UIFont(name: fontNameString!, size: fontSize)

        lastName.font = UIFont(name: fontNameString!, size: fontSize)

        phoneNumber.font = UIFont(name: fontNameString!, size: fontSize)

        parentName.font = UIFont(name: fontNameString!, size: fontSize)

        emailAddress.font = UIFont(name: fontNameString!, size: fontSize)

        cellNumber.font = UIFont(name: fontNameString!, size: fontSize)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
                // Configure the view for the selected state
    }
    
    @IBAction func GoToRespectiveAnswerView(_ sender: AnyObject) {
    }
    
}

