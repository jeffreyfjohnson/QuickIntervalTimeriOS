//
//  IntervalTableViewController.swift
//  QuickIntervalTimer
//
//  Created by Jeffrey Johnson on 1/27/17.
//  Copyright © 2017 Jeffrey Johnson. All rights reserved.
//

import UIKit

class IntervalTableViewCell : UITableViewCell{
    
    @IBOutlet var durationLabel: UILabel!
    @IBOutlet var soundIcon: UIImageView!
    @IBOutlet var soundDurationLabel: UILabel!
    @IBOutlet var colorLabel: UIImageView!
    
}

class IntervalTableViewController: UITableViewController {
    
    var intervalTimer: IntervalTimer!
    var onOnlyItemDeleted: (() -> ())?
    
    func addInterval(interval: Interval){
        intervalTimer.intervalList.append(interval)
        updateInsert(intervalTimer.numberOfIntervals()-1, end: intervalTimer.numberOfIntervals()-1)
    }
    
    func addIntervalToStart(interval: Interval){
        intervalTimer.intervalList.insert(interval, atIndex: 0)
        updateInsert(0, end: 0)
    }
    
    func editInterval(atIndex index: Int, newInterval: Interval){
        intervalTimer.intervalList.removeAtIndex(index)
        intervalTimer.intervalList.insert(newInterval, atIndex: index)
        tableView.beginUpdates()
        tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: UITableViewRowAnimation.None)
        tableView.endUpdates()
    }
    
    func repeatIntervals(numberOfTimes: Int){
        let oldCount = intervalTimer.numberOfIntervals()
        intervalTimer.repeatIntervals(numberOfTimes)
        updateInsert(oldCount, end: intervalTimer.numberOfIntervals()-1)
    }
    
    private func updateInsert(start: Int, end: Int){
        var indexArray = [Int]()
        indexArray += start...end
        let path = indexArray.map({ index in
            NSIndexPath(forItem: index, inSection: 0)
        })
        tableView.beginUpdates()
        let animation = (intervalTimer.numberOfIntervals() > 0 && start == 0) ? UITableViewRowAnimation.Top : UITableViewRowAnimation.Bottom
        tableView.insertRowsAtIndexPaths(path, withRowAnimation: animation)
        tableView.endUpdates()
        tableView.scrollToRowAtIndexPath(path.last!, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
    }
    
    func clear(){
        intervalTimer.clear()
        tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return intervalTimer.numberOfIntervals()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("IntervalTableViewCell", forIndexPath: indexPath) as! IntervalTableViewCell
        let interval = intervalTimer.intervalList[indexPath.row]
        
        cell.durationLabel.text = TimeUtils.formatTimeForListDisplay(interval.duration)
        
        cell.soundIcon.hidden = !interval.ringBellAtEnd
        cell.soundDurationLabel.hidden = !interval.ringBellAtEnd || interval.beepStartSeconds < 1
        cell.soundDurationLabel.text = String(interval.beepStartSeconds)
        
        cell.colorLabel.tintColor = interval.color
        
        return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == .Delete{
            intervalTimer.removeInterval(atIndex: indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            if (tableView.numberOfRowsInSection(0) < 1){
                onOnlyItemDeleted?()
            }
        }
    }
    
    override func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        
        intervalTimer.moveIntervalAtIndex(sourceIndexPath.row, toIndex: destinationIndexPath.row)
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "edit_interval_segue"){
            let timeSelectViewController = segue.destinationViewController as! TimeModalViewController
            let index = tableView.indexPathForSelectedRow?.row
            if let selectedIndex = index{
                timeSelectViewController.currentInterval = intervalTimer.intervalList[selectedIndex]
                timeSelectViewController.onTimeSelected = {[weak self]
                    (minutes, seconds, insertAtStart, bellAtEnd, beepSeconds, color) in
                    if let weakSelf = self{
                        let totalSeconds = TimeUtils.getTotalSeconds(minutes: minutes, seconds: seconds)
                        let intervalToEdit = Interval(duration: totalSeconds, beepStartSeconds: beepSeconds, ringBellAtEnd: bellAtEnd, color: color)
                        weakSelf.editInterval(atIndex: selectedIndex, newInterval: intervalToEdit)
                    }
                }
                
            }
        }
    }
}
