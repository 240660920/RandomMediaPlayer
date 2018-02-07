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

class MusicPlayer: AVAudioPlayer {
    init(resourcePath: String) {
        do {
            let url = URL(fileURLWithPath: resourcePath)
            
            try super.init(contentsOf: url, fileTypeHint: nil)
            
        } catch {
            let alert = UIAlertController(title: "播放错误", message: nil, preferredStyle: UIAlertControllerStyle.alert)
            let action = UIAlertAction(title: "确定", style: UIAlertActionStyle.default, handler: { (action) in
                alert.dismiss(animated: false, completion: nil)
            })
            alert.addAction(action)
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }

    @discardableResult override func play() -> Bool {
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [MPMediaItemPropertyTitle : MusicManager.currentMusic()?.name ?? "" , MPMediaItemPropertyArtist : MusicManager.currentMusic()?.artist ?? "" , MPMediaItemPropertyArtwork : MPMediaItemArtwork(boundsSize: CGSize(width: 100, height: 100), requestHandler: { (size) -> UIImage in
            return MusicManager.currentMusic()?.artwork ?? #imageLiteral(resourceName: "play")
        }) , MPNowPlayingInfoPropertyElapsedPlaybackTime : Int(self.currentTime) , MPMediaItemPropertyPlaybackDuration : self.duration , MPNowPlayingInfoPropertyPlaybackRate : 1.0]
        
        let result = super.play()
        
        if result {
            MPNowPlayingInfoCenter.default().playbackState = MPNowPlayingPlaybackState.playing
        }
        
        return result
    }
    
    override func pause() {
        super.pause()
        
        var info = MPNowPlayingInfoCenter.default().nowPlayingInfo
        info![MPNowPlayingInfoPropertyElapsedPlaybackTime] = Int(self.currentTime)
        info![MPNowPlayingInfoPropertyPlaybackRate] = 0
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
        
        MPNowPlayingInfoCenter.default().playbackState = MPNowPlayingPlaybackState.paused
    }
}
