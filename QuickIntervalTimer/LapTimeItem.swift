//
//  LapTimeItem.swift
//  QuickIntervalTimer
//
//  Created by Jeffrey Johnson on 1/23/17.
//  Copyright © 2017 Jeffrey Johnson. All rights reserved.
//

import UIKit

class LapTimeItem: NSObject {
    var index: Int
    var time: NSTimeInterval
    
    init(index:Int, time:NSTimeInterval) {
        self.index = index
        self.time = time
    }
}
