//
//  TimeUtils.swift
//  QuickIntervalTimer
//
//  Created by Jeffrey Johnson on 1/23/17.
//  Copyright © 2017 Jeffrey Johnson. All rights reserved.
//

import Foundation

class TimeUtils {
    class func formatTimeForTimer(interval: NSTimeInterval) ->String{
        let time = getMinsSecondsMillis(interval)
        return formatTime(time.mins, secs: time.secs, millis: time.millis)
    }
    
    class func formatTimeForLapDisplay(interval: NSTimeInterval) -> String{
        let time = getMinsSecondsMillis(interval)
        return formatTimeOmitLeadingZeros(time.mins, secs: time.secs, millis: time.millis)
    }
    
    class func formatTimeForListDisplay(interval: Int) -> String{
        let time = getMinsSecondsMillis(NSTimeInterval(interval))
        return formatTime(time.mins, secs: time.secs)
    }
    
    class func formatTimeForEditDisplay(minutes: Int, seconds: Int) -> String{
        return String(format: "%02d:%02d", arguments: [minutes, seconds])
    }
    
    class func getMinsSeconds(string: String) ->(minutes: Int, seconds: Int){
        let stringSplit = string.componentsSeparatedByString(":")
        return (Int(stringSplit[0])!, Int(stringSplit[1])!)
    }
    
    class func getTotalSeconds(minutes minutes: Int, seconds: Int) -> Int{
        return seconds + (minutes*60)
    }
    
    private class func formatTime(mins: Int, secs: Int) -> String{
        if (mins > 0){
            return String(format: "%1d:%02d", arguments: [mins, secs])
        }
        else{
            return String(format: "0:%02d", arguments: [secs])
        }
    }
    
    private class func formatTime(mins: Int, secs: Int, millis: Int) -> String{
        return String(format: "%02d:%02d.%02d", arguments: [mins,secs,millis])
    }
    
    private class func formatTimeOmitLeadingZeros(mins: Int, secs: Int, millis: Int) -> String{
        if (mins > 0){
            return String(format: "%2d:%02d.%02d", arguments: [mins, secs, millis])
        }
        else{
            return String(format: "%02d.%02d", arguments: [secs, millis])
        }
    }
    
    class func getMinsSecondsMillis(interval: NSTimeInterval) -> (mins: Int, secs: Int, millis: Int){
        let mins: Int = Int(interval) / 60
        let secs: Int = Int(interval) - mins * 60
        let millis: Int = Int(floor(interval*100)) - (secs*100) - (mins*60*100)
        
        return (mins, secs, millis)
    }
}
