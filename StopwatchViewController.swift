//
//  StopwatchViewController.swift
//  QuickIntervalTimer
//
//  Created by Jeffrey Johnson on 1/17/17.
//  Copyright © 2017 Jeffrey Johnson. All rights reserved.
//

import UIKit

class StopwatchViewController : UIViewController, TimeUpdateDelegate{
    var clock = Clock()
    @IBOutlet var timerLabel: UILabel!
    @IBOutlet var startPauseButton: UIButton!
    @IBOutlet var resetLapButton: UIButton!
    var lapTimeTableViewController: LapTimeTableViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        clock.timeUpdateDelegate = self
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "applicationDidEnterBackground", name: UIApplicationDidEnterBackgroundNotification, object: nil)
        notificationCenter.addObserver(self, selector: "applicationWillEnterForeground", name: UIApplicationWillEnterForegroundNotification, object: nil)
    }
    
    func applicationDidEnterBackground(){
        if clock.isRunning{
            clock.recordPause()
            clock.toggleStartPause(false)
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
    
    @IBAction func startPauseTapped(button: UIButton){
        if (clock.isRunning){
            clock.toggleStartPause(false)
            UIView.performWithoutAnimation({
                self.startPauseButton.setTitle("Start", forState: .Normal)
                self.startPauseButton.layoutIfNeeded()
                self.resetLapButton.setTitle("Reset", forState: .Normal)
                self.resetLapButton.layoutIfNeeded()
            })
        }
        else{
            clock.toggleStartPause(true)
            UIView.performWithoutAnimation({
                self.startPauseButton.setTitle("Pause", forState: .Normal)
                self.startPauseButton.layoutIfNeeded()
                self.resetLapButton.setTitle("Lap", forState: .Normal)
                self.resetLapButton.layoutIfNeeded()
            })
            
        }
    }
    
    @IBAction func resetLapTapped(button: UIButton){
        if (!clock.isRunning){
            clock.reset()
            lapTimeTableViewController.resetLapTimes()
        }
        else{
            lapTimeTableViewController.addLapTime(clock.elapsedTime)
        }
    }
    
    func onTimeUpdated(time: NSTimeInterval) {
        timerLabel.text = TimeUtils.formatTimeForTimer(time)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "lap_time_table_embed"){
            lapTimeTableViewController = segue.destinationViewController as! LapTimeTableViewController
        }
    }
}

