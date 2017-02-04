//
//  AnimationCircle.swift
//  QuickIntervalTimer
//
//  Created by Jeffrey Johnson on 2/2/17.
//  Copyright © 2017 Jeffrey Johnson. All rights reserved.
//

import UIKit
import GLKit

class AnimationView: UIView {
    var currentOuterAngle: Float = -90
    var currentInnerAngle: Float = -90{
        didSet{
            setNeedsDisplay()
        }
    }
    
    var circleColor: UIColor?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initHelper()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initHelper()
    }
    
    func initHelper(){
        self.backgroundColor = UIColor.clearColor()
    }
    
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        let outerPath = CGPathCreateMutable()
        let innerPath = CGPathCreateMutable()
        
        let outerCircleCenter = CGPoint(x: frame.width/2.0, y: frame.height/2.0)
        let outerRadius = frame.width/2 - 5
        
        let innerCircleCenter = outerCircleCenter
        let innerRadius = outerRadius - 5
        
        CGPathAddArc(outerPath, nil, outerCircleCenter.x, outerCircleCenter.y, outerRadius, -CGFloat(GLKMathDegreesToRadians(90)), CGFloat(GLKMathDegreesToRadians(currentOuterAngle)), false)

        CGContextAddPath(context, outerPath)
        CGContextSetStrokeColorWithColor(context, (circleColor ?? UIColor.blueColor()).CGColor)
        CGContextSetFillColorWithColor(context, (circleColor ?? UIColor.blueColor()).CGColor)
        CGContextSetLineWidth(context, 3)
        CGContextStrokePath(context)
        
        CGPathAddArc(innerPath, nil, innerCircleCenter.x, innerCircleCenter.y, innerRadius, -CGFloat(GLKMathDegreesToRadians(90)), CGFloat(GLKMathDegreesToRadians(currentInnerAngle)), true)
        CGContextAddPath(context, innerPath)
        CGContextEOFillPath(context)
    }
    
}
