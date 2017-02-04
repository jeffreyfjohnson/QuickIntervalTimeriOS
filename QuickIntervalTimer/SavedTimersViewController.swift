//
//  SavedTimersViewController.swift
//  QuickIntervalTimer
//
//  Created by Jeffrey Johnson on 2/1/17.
//  Copyright © 2017 Jeffrey Johnson. All rights reserved.
//

import UIKit

class SavedTimersViewController: UITableViewController {
    
    var currentTimer: IntervalTimer?
    var onTimerSelected: ((timer: IntervalTimer) ->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = editButtonItem()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        navigationController?.toolbarHidden = false
    }
    
    override func viewDidDisappear(animated: Bool) {
        navigationController?.toolbarHidden = true
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("UITableViewCell", forIndexPath: indexPath)
        
        let timer = IntervalTimerArchive.sharedInstance.timers[indexPath.row]
        
        cell.textLabel?.text = timer.name
        cell.detailTextLabel?.text = String(format: "%1d intervals", arguments: [timer.numberOfIntervals()])
        
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return IntervalTimerArchive.sharedInstance.savedTimersCount()
    }
    
    override func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        IntervalTimerArchive.sharedInstance.moveTimer(atIndex: sourceIndexPath.row, toIndex: destinationIndexPath.row)
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete{
            IntervalTimerArchive.sharedInstance.removeTimer(atIndex: indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let index = indexPath.row
        onTimerSelected?(timer: IntervalTimerArchive.sharedInstance.timerAtIndex(index))
        IntervalTimerArchive.sharedInstance.moveTimer(atIndex: index, toIndex: 0)
        navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func addTimerToArchive(timer: IntervalTimer){
        IntervalTimerArchive.sharedInstance.addTimer(timer)
        tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .Top)
        currentTimer = IntervalTimerArchive.sharedInstance.deepCopy(timer: timer)
        onTimerSelected?(timer: currentTimer!)
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier == "timer_name_segue"{
            if let timer = currentTimer{
                if timer.numberOfIntervals() > 0{
                    return true
                }
            }
            let alert = UIAlertController(title: "Error", message: "Can't save a timer with no intervals", preferredStyle: .Alert)
            let okButton = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
            alert.addAction(okButton)
            presentViewController(alert, animated: false){}
        }
        return false
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "timer_name_segue"{
            let nameViewController = segue.destinationViewController as! TimerNameViewController
            
            nameViewController.onNameEntered = { [weak self]
                (name) in
                if let weakSelf = self{
                    weakSelf.currentTimer!.name = name
                    weakSelf.addTimerToArchive(weakSelf.currentTimer!)
                }
                
            }
            nameViewController.currentName = currentTimer?.name
        }
    }
    
}
