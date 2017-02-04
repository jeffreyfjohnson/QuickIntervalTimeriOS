//
//  Clock.swift
//  QuickIntervalTimer
//
//  Created by Jeffrey Johnson on 1/23/17.
//  Copyright © 2017 Jeffrey Johnson. All rights reserved.
//

import UIKit

class Clock {
    
    var timer: NSTimer? = NSTimer()
    var isRunning = false
    var addTime: Double = 0
    
    var elapsedTime: Double = 0;
    var startDate: NSDate!
    var timeUpdateDelegate: TimeUpdateDelegate!
    
    var pauseTime: NSDate?
    
    func toggleStartPause(start: Bool){
        if (!start){
            timer?.invalidate()
            timer = nil
            if let date = startDate{
                addTime += NSDate().timeIntervalSince1970 - date.timeIntervalSince1970
            }
            isRunning = false
        }
        else{
            timer = NSTimer.scheduledTimerWithTimeInterval(0.075, target: self, selector: "onClockTick", userInfo: nil, repeats: true)
            startDate = NSDate()
            isRunning = true;
        }
    }
    
    dynamic func onClockTick() {
        elapsedTime = addTime + NSDate().timeIntervalSince1970 - startDate.timeIntervalSince1970
        timeUpdateDelegate?.onTimeUpdated(elapsedTime)
    }
    
    func updateTime(time: NSTimeInterval){
        timeUpdateDelegate?.onTimeUpdated(0)
    }
    
    func reset(){
        addTime = 0
        elapsedTime = 0
        updateTime(0)
    }
    
    func recordPause(){
        pauseTime = NSDate()
    }
    
    func restartIfTemporarilyPaused(){
        if let time = pauseTime{
            addTime += NSDate().timeIntervalSince1970 - time.timeIntervalSince1970
            toggleStartPause(true)
            pauseTime = nil
        }
    }
    
}

protocol TimeUpdateDelegate{
    func onTimeUpdated(time: NSTimeInterval)
}