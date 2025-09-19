//
//  AudioService.swift
//  tictak
//
//  Created by Leonardo Nápoles on 9/18/25.
//

import Foundation
import AVFoundation

class AudioService {
    private var audioPlayer: AVAudioPlayer?
    
    func playSound(named fileName: String) {
        guard let url = Bundle.main.url(forResource: fileName.components(separatedBy: ".").first, withExtension: fileName.components(separatedBy: ".").last)
        else {
            print("error: sound file '\(fileName)' not found.")
            return
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch let error {
            print("Error playing sound: \(error.localizedDescription)")
        }
    }
}
