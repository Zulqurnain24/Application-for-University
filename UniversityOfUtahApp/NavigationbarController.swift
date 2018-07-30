//
//  ViewController.swift
//  Swift Slide View
//
//  Created by Mohammad Zulqurnain on 13/08/16.
//

import UIKit

class NavigationbarController: UINavigationController, UIViewControllerTransitioningDelegate {

    var fontSize = CGFloat()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Status bar white font
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.navigationBar.barStyle = UIBarStyle.black
        self.navigationBar.tintColor = UIColor.white
        self.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name:appDelegate.fontNameString!, size:fontSize)!]
        self.navigationBar.topItem!.title = "Software Club Management"
    }
}
