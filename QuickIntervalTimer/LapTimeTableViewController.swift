//
//  LapTimeTableViewController.swift
//  QuickIntervalTimer
//
//  Created by Jeffrey Johnson on 1/23/17.
//  Copyright © 2017 Jeffrey Johnson. All rights reserved.
//

import UIKit

class LapTimeTableViewController: UITableViewController {
    
    var totalAccountedTime: Double = 0;
    var lapTimes = [LapTimeItem]()
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lapTimes.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("UITableViewCell", forIndexPath: indexPath)
        
        let lapTime = lapTimes[indexPath.row]
        
        cell.textLabel?.text = TimeUtils.formatTimeForLapDisplay(lapTime.time )
        cell.detailTextLabel?.text = String(lapTime.index)
        
        return cell
    }
    
    func addLapTime(absoluteTime: NSTimeInterval){
        lapTimes.append(LapTimeItem(index: lapTimes.count+1, time: absoluteTime - totalAccountedTime))
        let path = [NSIndexPath(forItem: lapTimes.count-1, inSection: 0)]
        tableView.beginUpdates()
        tableView.insertRowsAtIndexPaths(path, withRowAnimation: UITableViewRowAnimation.Bottom)
        tableView.endUpdates()
        tableView.scrollToRowAtIndexPath(path[0], atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
        totalAccountedTime += absoluteTime-totalAccountedTime
    }
    
    func resetLapTimes(){
        totalAccountedTime = 0;
        lapTimes.removeAll()
        tableView.reloadData()
    }
    
}
