//
//  SoundManager.swift
//  Finder
//
//  Created by Tai on 6/21/20.
//  Copyright © 2020 DJay. All rights reserved.
//

import Foundation
import AVFoundation

class SoundManager {
    
    public static var shared = SoundManager()
    
    private var messageSoundEffect: AVAudioPlayer?
    
    init() {
        self.createMessageSound()
    }
    
    private func createMessageSound() {
        
        let path = Bundle.main.path(forResource: "message_tone.mp3", ofType:nil)!
        let url = URL(fileURLWithPath: path)
        
        do {
            self.messageSoundEffect = try AVAudioPlayer(contentsOf: url)
        } catch {}
    }
    
    func playMessageSound() {
        self.messageSoundEffect?.play()
    }
}
