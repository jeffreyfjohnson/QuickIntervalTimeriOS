//
//  ColorUtils.swift
//  QuickIntervalTimer
//
//  Created by Jeffrey Johnson on 1/28/17.
//  Copyright © 2017 Jeffrey Johnson. All rights reserved.
//

import UIKit

// from http://stackoverflow.com/questions/24263007/how-to-use-hex-colour-values-in-swift-ios
extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
    
    func invert() -> UIColor{
        var r = CGFloat(0.0),g = CGFloat(0.0),b = CGFloat(0.0), a = CGFloat(0.0)
        getRed(&r, green: &g, blue: &b, alpha: &a)
        return UIColor(red: 1.0 - r, green: 1.0 - g, blue: 1.0 - b, alpha: a)
    }
}
