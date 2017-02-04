//
//  TimerViewController.swift
//  QuickIntervalTimer
//
//  Created by Jeffrey Johnson on 1/24/17.
//  Copyright © 2017 Jeffrey Johnson. All rights reserved.
//

import UIKit

class TimerViewController: UIViewController, TimeUpdateDelegate {
    var clock: Clock = Clock()
    var intervalTimer: IntervalTimer!
    var totalDuration: Int = 0
    
    var beepCount:Double = 0
    
    @IBOutlet var resetButton: UIButton!
    @IBOutlet var startPauseButton: UIButton!
    @IBOutlet var timerLabel: UILabel!
    @IBOutlet var circleView: AnimationView!
    
    @IBOutlet var upNextLabel: UILabel!
    @IBOutlet var intervalNumberLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad();
        clock.timeUpdateDelegate = self
        totalDuration = intervalTimer.totalDuration()
        onTimeUpdated(0)
        setBackgroundColor()
        setInfoLabels()
        createButtonBackground(forButton: startPauseButton)
        createButtonBackground(forButton: resetButton)
        
        AudioManager.sharedInstance.prepare()
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "applicationDidEnterBackground", name: UIApplicationDidEnterBackgroundNotification, object: nil)
        notificationCenter.addObserver(self, selector: "applicationWillEnterForeground", name: UIApplicationWillEnterForegroundNotification, object: nil)
    }
    
    func applicationDidEnterBackground(){
        if clock.isRunning{
            clock.recordPause()
            clock.toggleStartPause(false)
            
            let notif = UILocalNotification()
            notif.fireDate = NSDate(timeIntervalSinceNow: 2)
            notif.timeZone = NSTimeZone.defaultTimeZone()
            notif.alertBody = "asdf"
            notif.soundName = UILocalNotificationDefaultSoundName
            UIApplication.sharedApplication().scheduleLocalNotification(notif)
        }
    }
    
    func applicationWillEnterForeground(){
        clock.restartIfTemporarilyPaused()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.sharedApplication().idleTimerDisabled = true
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        UIApplication.sharedApplication().idleTimerDisabled = false
    }
    
    func createButtonBackground(forButton button: UIButton){
        button.layer.cornerRadius = 5
        button.layer.backgroundColor = UIColor(white: 1.0, alpha: 0.85).CGColor
        
    }
    
    override func didMoveToParentViewController(parent: UIViewController?) {
        clock.toggleStartPause(false)
        clock.reset()
        intervalTimer.reset()
    }
    
    @IBAction func onStartPauseTapped(sender: UIButton) {
        if (clock.isRunning){
            clock.toggleStartPause(false)
            UIView.performWithoutAnimation({
                self.startPauseButton.setTitle("Start", forState: .Normal)
                self.startPauseButton.layoutIfNeeded()
            })
            showHideButton(resetButton, show: true)
        }
        else{
            clock.toggleStartPause(true)
            UIView.performWithoutAnimation({
                self.startPauseButton.setTitle("Pause", forState: .Normal)
                self.startPauseButton.layoutIfNeeded()
            })
            showHideButton(resetButton, show: false)
        }

    }
    
    func showHideButton(button: UIButton, show: Bool){
        UIView.animateWithDuration(0.15, animations: {
            if (show){
                button.hidden = false
            }
            button.alpha = show ? 1 : 0
            }, completion:{
                (finished: Bool) in
                if (!show){
                    button.hidden = true
                }
        })

    }
    
    @IBAction func onResetTapped(sender: UIButton) {
        if (!clock.isRunning){
            intervalTimer.reset()
            clock.reset()
            setBackgroundColor()
            setInfoLabels()
            beepCount = 0
            if (startPauseButton.hidden){
                showHideButton(startPauseButton, show: true)
            }
        }
    }
    
    func setBackgroundColor(){
        if let interval = intervalTimer.currentInterval{
            view.backgroundColor = interval.color
            circleView.circleColor = interval.color.invert()
        }
    }
    
    func setInfoLabels(){
        if let _ = intervalTimer.currentInterval{
            
            let currentIndex = intervalTimer.currentIntervalIndex + 1
            let totalIntervals = intervalTimer.numberOfIntervals()
            intervalNumberLabel.text = String(format: "%1d/%1d", arguments: [currentIndex, totalIntervals])
            
            let upNextText: String
            if !intervalTimer.isOnLastInterval(){
                upNextText = TimeUtils.formatTimeForListDisplay(intervalTimer.intervalList[currentIndex].duration)
            }
            else{
                upNextText = ""
            }
            upNextLabel.text = upNextText
        }
    }
    
    func onTimeUpdated(time: NSTimeInterval) {
        
        guard let currentInterval = intervalTimer.currentInterval else{
            return
        }
        var timeLeftInInterval = Double(currentInterval.duration) - (time - Double(intervalTimer.completedIntervalTime))
        
        if (timeLeftInInterval <= 0){
            timeLeftInInterval = 0
            if (intervalTimer.isOnLastInterval()){
                showHideButton(startPauseButton, show: false)
                showHideButton(resetButton, show: true)
                clock.toggleStartPause(false)
                UIView.performWithoutAnimation({
                    self.startPauseButton.setTitle("Start", forState: .Normal)
                    self.startPauseButton.layoutIfNeeded()
                })
                AudioManager.sharedInstance.playEndBell()
            }
            else{
                if currentInterval.ringBellAtEnd{
                    AudioManager.sharedInstance.playBell()
                }
                intervalTimer.nextInterval()
                setBackgroundColor()
                setInfoLabels()
            }
            beepCount = 0
        }
        else{
            let beepTime = Double(currentInterval.beepStartSeconds) - beepCount
            if (beepTime > 0 && timeLeftInInterval <= beepTime){
                AudioManager.sharedInstance.playBeep()
                beepCount++
            }
        }
        timerLabel.text = TimeUtils.formatTimeForTimer(timeLeftInInterval)
        
        let doneRatio = timeLeftInInterval/Double(currentInterval.duration)
        circleView.currentOuterAngle = Float(270.0 - 360.0 * doneRatio)
        let totalDoneRatio = (Double(currentInterval.duration) - timeLeftInInterval + Double(intervalTimer.completedIntervalTime))/Double(totalDuration)
        circleView.currentInnerAngle = Float(-90.0 - 360.0 * totalDoneRatio)
    }
}
