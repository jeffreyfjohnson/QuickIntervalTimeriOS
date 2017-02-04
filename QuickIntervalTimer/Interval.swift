//
//  Interval.swift
//  QuickIntervalTimer
//
//  Created by Jeffrey Johnson on 1/24/17.
//  Copyright © 2017 Jeffrey Johnson. All rights reserved.
//

import UIKit

class Interval: NSObject, NSCoding {
    var duration: Int
    var beepStartSeconds: Int
    var ringBellAtEnd: Bool
    var color: UIColor
    
    init(duration: Int, beepStartSeconds: Int, ringBellAtEnd: Bool, color: UIColor){
        self.duration = duration
        self.beepStartSeconds = beepStartSeconds
        self.ringBellAtEnd = ringBellAtEnd
        self.color = color
    }
    
    convenience init(duration:Int){
        self.init(duration: duration,beepStartSeconds: 0,ringBellAtEnd: false, color: UIColor.whiteColor())
    }
    
    required init(coder aDecoder: NSCoder) {
        duration = aDecoder.decodeIntegerForKey("duration")
        beepStartSeconds = aDecoder.decodeIntegerForKey("beepStartSeconds")
        ringBellAtEnd = aDecoder.decodeBoolForKey("ringBellAtEnd")
        color = aDecoder.decodeObjectForKey("color") as! UIColor
    }
    
    class func deepCopy(intervalToCopy: Interval) -> Interval{
        return Interval(duration: intervalToCopy.duration, beepStartSeconds: intervalToCopy.beepStartSeconds, ringBellAtEnd: intervalToCopy.ringBellAtEnd, color: intervalToCopy.color.copy() as! UIColor)
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInteger(duration, forKey: "duration")
        aCoder.encodeInteger(beepStartSeconds, forKey: "beepStartSeconds")
        aCoder.encodeBool(ringBellAtEnd, forKey: "ringBellAtEnd")
        aCoder.encodeObject(color, forKey: "color")
    }
    
}
