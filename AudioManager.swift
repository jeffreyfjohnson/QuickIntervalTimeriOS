//
//  AudioManager.swift
//  QuickIntervalTimer
//
//  Created by Jeffrey Johnson on 2/1/17.
//  Copyright © 2017 Jeffrey Johnson. All rights reserved.
//

import UIKit
import AVFoundation

class AudioManager {
    
    var beepAudioPlayer: AVAudioPlayer?
    var bellAudioPlayer: AVAudioPlayer?
    var bellAudioPlayer2: AVAudioPlayer?
    var bellAudioPlayer3: AVAudioPlayer?
    
    static let sharedInstance = AudioManager()
    private init(){
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
        let beepURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("beep", ofType: ".wav") ?? "")
        let bellURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("boxing_bell", ofType: ".wav") ?? "")
        beepAudioPlayer = try? AVAudioPlayer(contentsOfURL: beepURL)
        bellAudioPlayer = try? AVAudioPlayer(contentsOfURL: bellURL)
        bellAudioPlayer2 = try? AVAudioPlayer(contentsOfURL: bellURL)
        bellAudioPlayer3 = try? AVAudioPlayer(contentsOfURL: bellURL)
    }
    
    func prepare(){
        let queue = dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0)
        
        dispatch_async(queue){ [weak self] in
            if let weakSelf = self{
                weakSelf.bellAudioPlayer?.prepareToPlay()
                weakSelf.beepAudioPlayer?.prepareToPlay()
                weakSelf.bellAudioPlayer2?.prepareToPlay()
                weakSelf.bellAudioPlayer3?.prepareToPlay()
            }
        }
    }
    
    func playEndBell(){
        playBell()
        delay(0.25){
            self.bellAudioPlayer2?.play()
        }
        delay(0.5){
            self.bellAudioPlayer3?.play()
        }
    }
    
    func playBell(){
        bellAudioPlayer?.pause()
        bellAudioPlayer?.currentTime = 0
        bellAudioPlayer?.play()
    }
    
    func playBeep(){
        beepAudioPlayer?.play()
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
}
