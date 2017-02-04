//
//  ViewController.swift
//  QuickIntervalTimer
//
//  Created by Jeffrey Johnson on 1/17/17.
//  Copyright © 2017 Jeffrey Johnson. All rights reserved.
//

import UIKit

class TimerSetupViewController: UIViewController {
    
    var intervalTableViewController: IntervalTableViewController!
    var intervalTimer = IntervalTimer(intervalList: [Interval]())
    @IBOutlet var startButton: UIButton!
    @IBOutlet var repeatClearButton: UIButton!
    @IBOutlet var timeButton: UIButton!
    @IBOutlet var editDoneButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateButtons()
        startButton.clipsToBounds = true
        startButton.layer.cornerRadius = 5
        startButton.layer.borderWidth = 1
        startButton.layer.borderColor = UIColor.lightGrayColor().CGColor
        
        timeButton.clipsToBounds = true
        timeButton.layer.cornerRadius = 5
        timeButton.layer.borderWidth = 1
        timeButton.layer.borderColor = UIColor.lightGrayColor().CGColor

    }
    
    override func viewDidAppear(animated: Bool) {
        navigationController?.toolbarHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func timeTapped(sender: AnyObject) {
        
    }
    
    @IBAction func startTapped(sender: AnyObject) {
    }
    
    @IBAction func repeatClearTapped(sender: AnyObject) {
        if (intervalTableViewController.editing){
            intervalTableViewController.clear()
            updateButtons()
            editDoneTapped(self)
        }
    }
    
    @IBAction func editDoneTapped(sender: AnyObject) {
        let currentlyEditing = !intervalTableViewController.editing
        intervalTableViewController.setEditing(currentlyEditing, animated: true)
        editDoneButton.setTitle(currentlyEditing ? "Done" : "Edit", forState: .Normal)
        repeatClearButton.setTitle(currentlyEditing ? "Clear" : "Repeat", forState: .Normal)
    }
    
    
    func updateButtons(){
        var enable = false
        if intervalTimer.numberOfIntervals() > 0{
            enable = true
        }
        
        startButton.enabled = enable
        repeatClearButton.enabled = enable
        editDoneButton.enabled = enable
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if (identifier == "countdown_push_segue" && intervalTimer.numberOfIntervals() < 1){
            return false
        }
        if (identifier == "repeat_select_segue" && intervalTableViewController.editing){
            return false
        }
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "interval_table_embed"){
            intervalTableViewController = segue.destinationViewController as! IntervalTableViewController
            intervalTableViewController.intervalTimer = intervalTimer
            intervalTableViewController.onOnlyItemDeleted = {[weak self]
                () in
                if let weakSelf = self{
                    weakSelf.repeatClearTapped(weakSelf)
                }
            }
        }
        else if (segue.identifier == "countdown_push_segue"){
            let timerViewController = segue.destinationViewController as! TimerViewController
            timerViewController.intervalTimer = intervalTimer
        }
        else if (segue.identifier == "time_select_segue"){
            let timeSelectViewController = segue.destinationViewController as! TimeModalViewController
            //need this to be weak reference to get out of reference cycle
            timeSelectViewController.onTimeSelected = {[weak self]
                (minutes, seconds, insertAtStart, bellAtEnd, beepSeconds, color) in
                if let weakSelf = self{
                    let totalSeconds = TimeUtils.getTotalSeconds(minutes: minutes, seconds: seconds)
                    let intervalToAdd = Interval(duration: totalSeconds, beepStartSeconds: beepSeconds, ringBellAtEnd: bellAtEnd, color: color)
                    if (insertAtStart){
                        weakSelf.intervalTableViewController.addIntervalToStart(intervalToAdd)
                    }else{
                        weakSelf.intervalTableViewController.addInterval(intervalToAdd)
                    }
                    weakSelf.updateButtons()
                }
            }
        }
        else if (segue.identifier == "repeat_select_segue"){
            let repeatSelectViewController = segue.destinationViewController as! RepeatModalViewController
            
            repeatSelectViewController.onRepeatNumberSelected = {[weak self]
                (repeatNumber) in
                if let weakSelf = self{
                    weakSelf.intervalTableViewController.repeatIntervals(repeatNumber)
                }
            }
        }
        else if (segue.identifier == "saved_timers_segue"){
            let savedTimersViewController = segue.destinationViewController as! SavedTimersViewController
            
            savedTimersViewController.currentTimer = intervalTimer
            savedTimersViewController.onTimerSelected = { [weak self]
                (timer) in
                if let weakSelf = self{
                    weakSelf.intervalTimer = timer
                    weakSelf.intervalTableViewController.intervalTimer = timer
                    weakSelf.updateButtons()
                    weakSelf.intervalTableViewController.tableView.reloadData()
                }
            }
        }
    }
}

