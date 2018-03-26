//
//  MusicPlayer.swift
//  RandomMediaPlayer
//
//  Created by xieran on 2018/2/6.
//  Copyright © 2018年 xieran. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

class MusicPlayer {
    var player: Any?
    
    init(music: Music) {
        (self.player as? AVAudioPlayer)?.pause()
        (self.player as? AudioStreamer)?.pause()
        
        if FileManager.default.fileExists(atPath: music.cachePath()) {
            do {
                try player = AVAudioPlayer(contentsOf: URL(fileURLWithPath: music.cachePath()))
            } catch {
                try? FileManager.default.removeItem(atPath: music.cachePath())
                
                configStreamPlayer(music)
            }
        } else {
            configStreamPlayer(music)
        }
    }
    
    func configStreamPlayer(_ music: Music) {
        player = AudioStreamer(url: URL(string: music.urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!))
        
        MusicManager.download(music)
    }
    
    func setDelegate(_ delegate: Any) {
        (self.player as? AVAudioPlayer)?.delegate = delegate as? AVAudioPlayerDelegate
    }

    func play() {
        
//        MPNowPlayingInfoCenter.default().nowPlayingInfo = [MPMediaItemPropertyTitle : MusicManager.currentMusic()?.name ?? "" , MPMediaItemPropertyArtist : MusicManager.currentMusic()?.artist ?? "" , MPMediaItemPropertyArtwork : MPMediaItemArtwork(image: MusicManager.currentMusic()?.artwork ?? #imageLiteral(resourceName: "play")) , MPNowPlayingInfoPropertyElapsedPlaybackTime : Int(self.currentTime) , MPMediaItemPropertyPlaybackDuration : self.duration , MPNowPlayingInfoPropertyPlaybackRate : 1.0]
        
        if self.player is AVAudioPlayer {
            (self.player as! AVAudioPlayer).play()
        } else {
            (self.player as! AudioStreamer).start()
        }
        
//        if result {
//            if #available(iOS 11.0, *) {
//                MPNowPlayingInfoCenter.default().playbackState = MPNowPlayingPlaybackState.playing
//            } else {
//                // Fallback on earlier versions
//            }
//        }
        
//        return result
    }
    
    func pause() {
        guard self.player != nil else {
            return
        }
        
        if self.player is AVAudioPlayer {
            if let _ = (self.player as? AVAudioPlayer)?.isPlaying {
                (self.player as? AVAudioPlayer)?.pause()
            }
        } else {
            if (self.player as! AudioStreamer).isPlaying() {
                (self.player as! AudioStreamer).pause()
            }
        }
        
//        var info = MPNowPlayingInfoCenter.default().nowPlayingInfo
//        info![MPNowPlayingInfoPropertyElapsedPlaybackTime] = Int(self.currentTime)
//        info![MPNowPlayingInfoPropertyPlaybackRate] = 0
//        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
//        
//        if #available(iOS 11.0, *) {
//            MPNowPlayingInfoCenter.default().playbackState = MPNowPlayingPlaybackState.paused
//        } else {
//            // Fallback on earlier versions
//        }
    }
}
