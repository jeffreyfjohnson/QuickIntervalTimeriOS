//
//  ModalViewControllers.swift
//  QuickIntervalTimer
//
//  Created by Jeffrey Johnson on 1/27/17.
//  Copyright © 2017 Jeffrey Johnson. All rights reserved.
//

import UIKit

class RepeatModalViewController: UIViewController, UITextFieldDelegate{
    
    var onRepeatNumberSelected: ((repeatCount: Int) -> ())?
    
    @IBOutlet var repeatCountTextField: UITextField!
    @IBOutlet var doneButton: UIButton!
    
    @IBAction func doneTapped(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: {})
        onRepeatNumberSelected?(repeatCount: Int(repeatCountTextField.text!)!)
    }
    
    @IBAction func dismissWithoutSelection(sender: AnyObject){
        dismissViewControllerAnimated(true, completion: {})
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        repeatCountTextField.delegate = self
        repeatCountTextField.becomeFirstResponder()
        repeatCountTextField.tintColor = UIColor.clearColor()
        doneButton.enabled = false
        doneButton.tintColor = UIColor.whiteColor()
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        //don't accept pasted text
        if string.characters.count > 1{
            return false
        }
        
        //don't accept anything but digits
        let nonDigitSet = NSCharacterSet(charactersInString: "1234567890").invertedSet
        if let _ = string.rangeOfCharacterFromSet(nonDigitSet) {
            return false
        }
        
        if (textField.text?.characters.count < 1 && (string == "" || string == "0")){
            return false
        }
        
        if (textField.text?.characters.count >= 2 && string != "" ){
            return false
        }
        
        //if backspace
        if (string == ""){
            let newString = textField.text?.substringToIndex((textField.text?.endIndex.predecessor())!)
            textField.text = newString ?? ""
        }
        else{
            textField.text = (textField.text ?? "") + string
        }
        
        doneButton.enabled = textField.text?.characters.count > 0
        doneButton.tintColor = doneButton.enabled ? UIColor(netHex: 0x2C951F) : UIColor.whiteColor()
        
        return false
    }
}

class TimeModalViewController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate {
    
    let blueColor = UIColor(netHex: 0x1552B5)
    let yellowColor = UIColor(netHex: 0xF9D107)
    let redColor = UIColor(netHex: 0xE00B24)
    
    var pointer: Int = 0
    var digits: [String] = ["0","0","0","0"]
    var currentInterval: Interval?
    
    var onTimeSelected: ((minutes: Int, seconds: Int, insertAtStart: Bool, roundEndBell: Bool, beepTimeSeconds: Int, roundColor: UIColor) -> ())?
    
    @IBOutlet var timeTextField: UITextField!
    @IBOutlet var doneButton: UIButton!
    @IBOutlet var insertAtStartSwitch: UISwitch!
    
    @IBOutlet var bellAtEndSwitch: UISwitch!
    @IBOutlet var beepTimeLabel: UILabel!
    @IBOutlet var beepTimeSlider: UISlider!
    
    @IBOutlet var whiteButton: UIButton!
    @IBOutlet var blueButton: UIButton!
    @IBOutlet var redButton: UIButton!
    @IBOutlet var yellowButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timeTextField.delegate = self
        timeTextField.tintColor = UIColor.whiteColor()
        view.gestureRecognizers?.first?.delegate = self
        
        whiteButton.selected = true
        highlightSelectedButton()
        
        if let interval = currentInterval{
            insertAtStartSwitch.enabled = false
            
            let time = TimeUtils.getMinsSecondsMillis(Double(interval.duration))
            let displayTime = TimeUtils.formatTimeForEditDisplay(time.mins, seconds: time.secs)
            
            timeTextField.text = displayTime
            digits[0] = String(displayTime[displayTime.startIndex])
            digits[1] = String(displayTime[displayTime.startIndex.advancedBy(1)])
            digits[2] = String(displayTime[displayTime.endIndex.advancedBy(-2)])
            digits[3] = String(displayTime[displayTime.endIndex.advancedBy(-1)])
            for (i,digit) in digits.enumerate(){
                if digit != "0"{
                    pointer = 4-i
                    break
                }
            }
            
            bellAtEndSwitch.on = interval.ringBellAtEnd
            beepTimeSlider.maximumValue = Float(min(10, interval.duration))
            let beepTime = interval.beepStartSeconds
            beepTimeSlider.value = Float(beepTime)
            beepTimeLabel.text = String(format: "%1d seconds", arguments: [beepTime])
            var tag: Int
            switch interval.color{
            case blueColor:
                tag = 1
                break
            case redColor:
                tag = 2
                break
            case yellowColor:
                tag = 3
                break
            default:
                tag = 0
                break
            }
            let dummyButton = UIButton()
            dummyButton.tag = tag
            onColorButtonSelected(dummyButton)
            
            doneButton.tintColor = UIColor(netHex: 0x2C951F)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        timeTextField.becomeFirstResponder()
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if (touch.view is UISlider){
            return false
        }
        return true
    }

    @IBAction func doneTapped(sender: AnyObject) {
        if (pointer > 0){
            dismissViewControllerAnimated(true, completion:{})
            let bellAtEnd = bellAtEndSwitch.on
            onTimeSelected?(minutes: Int(digits[0] + digits[1])!, seconds: Int(digits[2] + digits[3])!, insertAtStart: insertAtStartSwitch.on, roundEndBell: bellAtEnd, beepTimeSeconds: bellAtEnd ? Int(beepTimeSlider.value) : 0, roundColor: getSelectedColor())
        }
    }
    
    @IBAction func dismissWithoutTime(sender: AnyObject){
        if timeTextField.isFirstResponder(){
            timeTextField.resignFirstResponder()
        }
        else{
            dismissViewControllerAnimated(true, completion: {})
        }
    }
    
    @IBAction func onBellSwitchChanged(sender: AnyObject) {
        beepTimeLabel.enabled = bellAtEndSwitch.on
        beepTimeSlider.enabled = bellAtEndSwitch.on
    }
    @IBAction func onBeepSliderSet(sender: AnyObject) {
        beepTimeSlider.value = round(beepTimeSlider.value)
    }
    @IBAction func onBeepSliderValueChanged(sender: AnyObject) {
        let seconds = beepTimeSlider.value
        beepTimeLabel.text = String(format: "%1d seconds", arguments: [Int(seconds)])
    }
    
    @IBAction func onColorButtonSelected(sender: UIButton) {
        if (sender.tag == 0){
            whiteButton.selected = true
            blueButton.selected = false
            redButton.selected = false
            yellowButton.selected = false
        }
        else if (sender.tag == 1){
            whiteButton.selected = false
            blueButton.selected = true
            redButton.selected = false
            yellowButton.selected = false
        }
        else if (sender.tag == 2){
            whiteButton.selected = false
            blueButton.selected = false
            redButton.selected = true
            yellowButton.selected = false

        }
        else if (sender.tag == 3){
            whiteButton.selected = false
            blueButton.selected = false
            redButton.selected = false
            yellowButton.selected = true

        }
        highlightSelectedButton()
    }
    
    private func getSelectedColor() -> UIColor{
        if blueButton.selected{
            return blueColor
        }
        if redButton.selected{
            return redColor
        }
        if yellowButton.selected{
            return yellowColor
        }
        return UIColor.whiteColor()
    }
    
    private func highlightSelectedButton(){
        borderButton(whiteButton, highlight: whiteButton.selected)
        borderButton(blueButton, highlight: blueButton.selected)
        borderButton(redButton, highlight: redButton.selected)
        borderButton(yellowButton, highlight: yellowButton.selected)
    }
    
    private func borderButton(button: UIButton, highlight: Bool){
        button.layer.borderColor = highlight ? UIColor.yellowColor().CGColor : UIColor.clearColor().CGColor
        button.layer.borderWidth = highlight ? 2 : 1
        button.layer.cornerRadius = 5
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        //don't accept pasted text
        if string.characters.count > 1{
            return false
        }
        
        //don't accept anything but digits
        let nonDigitSet = NSCharacterSet(charactersInString: "1234567890").invertedSet
        if let _ = string.rangeOfCharacterFromSet(nonDigitSet) {
            return false
        }
        
        //don't accept 0 or backspace when we have no entered digits
        if (pointer <= 0 && (string == "0" || string == "")){
            return false
        }
        
        //only accept backspace when we have XX:XX
        if (pointer >= 4 && string != ""){
            return false
        }
        
        //if backspace
        if (string == ""){
            //move the current digit pointer back
            pointer--
            //remove the furthest right digit
            digits.removeAtIndex(3)
            //add 0 to the left
            digits.insert("0", atIndex: 0)
        }
        else{
            //add the new digit to the furthest right place
            digits.append(string)
            //remove the 0 at the head of the list to shift everything
            digits.removeAtIndex(0)
            //increment the current index
            pointer++
        }
        
        let duration: (minutes: Int, seconds: Int) = (Int(digits[0] + digits[1])!, Int(digits[2] + digits[3])!)
        textField.text = TimeUtils.formatTimeForEditDisplay(duration.minutes, seconds: duration.seconds)
        
        let maxValue = Float(min(10, 60*duration.minutes + duration.seconds))
        beepTimeSlider.maximumValue = maxValue
        beepTimeSlider.value = maxValue/2
        beepTimeLabel.text = String(format: "%1d seconds", arguments: [Int(maxValue/2)])
        
        if (pointer > 0){
            doneButton.tintColor = UIColor(netHex: 0x2C951F)
        }
        else{
            doneButton.tintColor = UIColor.whiteColor()
        }
        
        return false
        
    }
}
