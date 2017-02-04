//
//  IntervalTimerArchive.swift
//  QuickIntervalTimer
//
//  Created by Jeffrey Johnson on 2/2/17.
//  Copyright © 2017 Jeffrey Johnson. All rights reserved.
//

import Foundation

class IntervalTimerArchive{
    
    static let sharedInstance = IntervalTimerArchive()
    
    let intervalTimerArchiveURL: NSURL = {
        let documentsDirectories = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let documentDirectory = documentsDirectories.first!
        return documentDirectory.URLByAppendingPathComponent("intervals.archive")
    }()
    var timers = [IntervalTimer]()
    
    init(){
        if let savedItems = NSKeyedUnarchiver.unarchiveObjectWithFile(intervalTimerArchiveURL.path!) as? [IntervalTimer]{
            timers += savedItems
        }
    }
    
    func saveChanges() -> Bool{
        return NSKeyedArchiver.archiveRootObject(timers, toFile: intervalTimerArchiveURL.path!)
    }
    
    func savedTimersCount() -> Int{
        return timers.count
    }
    
    func timerAtIndex(index: Int) -> IntervalTimer{
        return deepCopy(timer: timers[index])
    }
    
    func deepCopy(timer timer: IntervalTimer) -> IntervalTimer{
        return NSKeyedUnarchiver.unarchiveObjectWithData(NSKeyedArchiver.archivedDataWithRootObject(timer)) as! IntervalTimer
    }
    
    func addTimer(timer: IntervalTimer){
        timers.insert(timer, atIndex: 0)
    }
    
    func moveTimerToTop(atIndex index: Int){
        moveTimer(atIndex: index, toIndex: 0)
    }
    
    func moveTimer(atIndex index: Int, toIndex: Int){
        if index == toIndex{
            return
        }
        let temp = timers[index]
        timers.removeAtIndex(index)
        timers.insert(temp, atIndex: toIndex)
    }
    
    func removeTimer(atIndex index: Int){
        timers.removeAtIndex(index)
    }
    
}