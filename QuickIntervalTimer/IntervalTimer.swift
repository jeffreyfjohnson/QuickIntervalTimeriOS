//
//  IntervalTimer.swift
//  QuickIntervalTimer
//
//  Created by Jeffrey Johnson on 1/24/17.
//  Copyright © 2017 Jeffrey Johnson. All rights reserved.
//

import Foundation

class IntervalTimer: NSObject, NSCoding {
    var name: String?
    var intervalList: [Interval]
    var currentIntervalIndex: Int{
        didSet{
            if (currentIntervalIndex == 0){
                completedIntervalTime = 0
                
            }
            else if (currentIntervalIndex > oldValue && !isTimerOver()){
                completedIntervalTime += intervalList[oldValue].duration ?? 0
            }
        }
    }
    var completedIntervalTime: Int
    var currentInterval: Interval?{
        if (currentIntervalIndex < intervalList.count){
            return intervalList[currentIntervalIndex]
        }
        else{
            return nil
        }
    }
    
    init(intervalList: [Interval]){
        self.intervalList = intervalList
        currentIntervalIndex = 0;
        completedIntervalTime = 0;
    }
    
    required init(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObjectForKey("name") as? String
        intervalList = aDecoder.decodeObjectForKey("intervalList") as! [Interval]
        currentIntervalIndex = 0;
        completedIntervalTime = 0;
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: "name")
        aCoder.encodeObject(intervalList, forKey: "intervalList")
    }
    
    func nextInterval() -> Interval?{
        currentIntervalIndex++
        //current interval updated in 'didSet'
        return currentInterval
    }
    
    func isTimerOver() -> Bool{
        return currentIntervalIndex >= numberOfIntervals()
    }
    
    func isOnLastInterval() -> Bool{
        return currentIntervalIndex == numberOfIntervals() - 1;
    }
    
    func numberOfIntervals() -> Int{
        return intervalList.count
    }
    
    func reset(){
        currentIntervalIndex = 0
    }
    
    func clear(){
        intervalList.removeAll()
        currentIntervalIndex = 0;
    }
    
    func removeInterval(atIndex index: Int){
        intervalList.removeAtIndex(index)
    }
    
    func totalDuration() -> Int{
        var sum = 0
        for interval in intervalList{
            sum += interval.duration
        }
        return sum
    }
    
    func moveIntervalAtIndex(atIndex: Int, toIndex: Int){
        if (atIndex == toIndex){
            return
        }
        
        let movedInterval = intervalList[atIndex]
        intervalList.removeAtIndex(atIndex)
        intervalList.insert(movedInterval, atIndex: toIndex)
    }
    
    func repeatIntervals(numberOfTimes: Int){
        let originalCount = intervalList.count
        for _ in 1...numberOfTimes{
            for i in 0..<originalCount{
                let newInterval = Interval.deepCopy(intervalList[i])
                intervalList.append(newInterval)
            }
        }
    }
}
