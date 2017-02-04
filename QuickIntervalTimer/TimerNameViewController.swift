//
//  TimerNameViewController.swift
//  QuickIntervalTimer
//
//  Created by Jeffrey Johnson on 2/2/17.
//  Copyright © 2017 Jeffrey Johnson. All rights reserved.
//

import UIKit

class TimerNameViewController: UIViewController,  UITextFieldDelegate{
    
    @IBOutlet var doneButton: UIButton!
    @IBOutlet var nameTextField: UITextField!
    
    var currentName: String?
    var onNameEntered: ((name: String) -> ())?
    
    override func viewDidLoad() {
        nameTextField.delegate = self
        nameTextField.addTarget(self, action: "onTextChanged", forControlEvents: .EditingChanged)
        nameTextField.becomeFirstResponder()
        
        if let name = currentName{
            nameTextField.text = name
            doneButton.enabled = true
            doneButton.tintColor = UIColor(netHex: 0x2C951F)
        }
        else{
            doneButton.enabled = false
            doneButton.tintColor = UIColor.whiteColor()
        }
    }
    
    @IBAction func doneTapped(sender: AnyObject) {
        onNameEntered?(name: nameTextField.text!)
        dismissViewControllerAnimated(true){}
    }
    
    @IBAction func viewTappedOutside(sender: AnyObject) {
            dismissViewControllerAnimated(true){}
    }
    
    func onTextChanged(){
        doneButton.enabled = nameTextField.text?.characters.count > 0
        doneButton.tintColor = doneButton.enabled ? UIColor(netHex: 0x2C951F) : UIColor.whiteColor()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.text?.characters.count > 0{
            doneTapped(self)
        }else{
            viewTappedOutside(self)
        }
        return true
    }
    
}
