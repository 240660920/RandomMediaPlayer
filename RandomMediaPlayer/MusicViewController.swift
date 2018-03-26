//
//  ViewController.swift
//  RandomMediaPlayer
//
//  Created by xieran on 2018/2/5.
//  Copyright © 2018年 xieran. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

class TrapezoidBackground: UIView {
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.move(to: CGPoint(x: 0, y: rect.height / 3 * 2))
        context?.addLine(to: CGPoint(x: rect.width, y: rect.height / 3))
        context?.addLine(to: CGPoint(x: rect.width, y: rect.height))
        context?.addLine(to: CGPoint(x: 0, y: rect.height))
        context?.addLine(to: CGPoint(x: 0, y: rect.height / 3 * 2))
        context?.setFillColor(UIColor(red: 0x21/255.0, green: 0x21/255.0, blue: 0x21/255.0, alpha: 1).cgColor)
        context?.fillPath()
    }
}

class MusicViewController: UIViewController,AVAudioPlayerDelegate {
    
    var musicPlayer: MusicPlayer!

    let cover = MusicCover()
    
    lazy var songNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 11)
        blackMask.addSubview(label)
        return label
    }()
    
    lazy var singerNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.textAlignment = .center;
        label.font = UIFont.systemFont(ofSize: 11)
        blackMask.addSubview(label)
        return label
    }()
    
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.black
        label.textAlignment = .center
        view.addSubview(label)
        return label
    }()
    
    lazy var blackMask: UIView = {
        let v = UIView(frame: CGRect(x: 23, y: 77, width: view.frame.width - 46, height: view.frame.height - 77 - (self.tabBarController?.tabBar.frame.size.height)!))
        v.backgroundColor = UIColor(red: 0x24/255.0, green: 0x24/255.0, blue: 0x24/255.0, alpha: 1)
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.5
        self.view.addSubview(v)
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: -1, y: 3))
        path.addLine(to: CGPoint(x: -1, y: self.view.frame.height))
        path.addLine(to: CGPoint(x: self.view.frame.width - 46 + 1, y: self.view.frame.height))
        path.addLine(to: CGPoint(x: self.view.frame.width - 46 + 1, y: 3))
        
        v.layer.shadowPath = path.cgPath
        
        return v
    }()
    
    lazy var controlView: MusicControlView = {
        let v = MusicControlView()
        blackMask.addSubview(v)
        return v
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        NotificationCenter.default.addObserver(self, selector: #selector(playInterrpted), name: Notification.Name.AVAudioSessionInterruption, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didGetMusicInfo(notice:)), name: Notification.Name.init("didGetMusicInfo"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(audioStreamerStateChanged(notice:)), name: NSNotification.Name.ASStatusChanged, object: nil)
        
        MPRemoteCommandCenter.shared().playCommand.addTarget(self, action: #selector(resumePlay))
        MPRemoteCommandCenter.shared().pauseCommand.addTarget(self, action: #selector(pause))
        MPRemoteCommandCenter.shared().previousTrackCommand.addTarget(self, action: #selector(remoteCommandPrevious))
        MPRemoteCommandCenter.shared().nextTrackCommand.addTarget(self, action: #selector(remoteCommandNext))
        
        view.backgroundColor = yellowBackgroundColor
        
        titleLabel.text = "Music"

        let trapeBg = TrapezoidBackground(frame: self.view.bounds)
        trapeBg.backgroundColor = UIColor.clear
        view.addSubview(trapeBg)
        
        view.addSubview(blackMask)
        
        cover.frame = CGRect(x: (blackMask.frame.width - 200) / 2, y: 82, width: 200, height: 200)
        cover.backgroundColor = blackMask.backgroundColor
        cover.imageLayer.contents = #imageLiteral(resourceName: "logo").cgImage
        blackMask.addSubview(cover)
        
        let segment = Bundle.main.loadNibNamed("MusicSegment", owner: nil, options: nil)![0] as! MusicSegment
        blackMask.addSubview(segment)
        segment.snp.makeConstraints { (make) in
            make.top.centerX.equalToSuperview()
            make.width.equalTo(269)
            make.height.equalTo(80)
        }
        segment.clickBlock = {(type: MusicListType) in
            MusicManager.listType = type
            
            self.prepare(true)
        }
        
        
        updateConstraints()

        
        controlView.playBlock = {(shoudPlay) -> Bool in
            guard self.musicPlayer != nil else {
                return false
            }
            
            if shoudPlay , MusicManager.currentMusic() != nil{
                self.musicPlayer.play()
                self.cover.startRotating()
                return true
            } else {
                self.cover.stopRotating()
                self.musicPlayer.pause()
                return false
            }
        }
        
        controlView.deleteBlock = {() in
            if let music = MusicManager.currentMusic() {
                MusicManager.delete(music)
                
                self.cover.imageLayer.contents = MusicManager.currentMusic()?.artwork ?? #imageLiteral(resourceName: "logo").cgImage
            } else {
                self.cover.imageLayer.contents = #imageLiteral(resourceName: "logo").cgImage
            }
            
            let shouldPlay = MusicManager.list(ofType: MusicManager.listType).count > 0
            self.prepare(shouldPlay)
            
            if MusicManager.likeArr.count == 0 {
                self.controlView.setFavor(false)                
            }
        }

        controlView.favorBlock = {(isFavor) in
            if let music = MusicManager.currentMusic() {
                MusicManager.like(music)
                
                return music.isFavor
            } else {
                return false
            }
        }
        

        MusicManager.initializeData()
                
        //准备好recommend列表的歌曲，但是不播放
        prepare(false)
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        prepare(true)
    }
    
    @objc func audioStreamerStateChanged(notice: Notification) {
        let streamer = notice.object as! AudioStreamer
        if streamer.state.rawValue == 8 , streamer.errorCode.rawValue == 0 {
            prepare(true)
        }
    }
    
    @objc func playInterrpted() {
        self.pause()
    }

    
    func prepare(_ shouldPlay: Bool) {
        if self.musicPlayer != nil {
            self.musicPlayer.pause()
        }
        
        let list = MusicManager.list(ofType: MusicManager.listType)
        if list.count > 0 {
            let random = Int(arc4random_uniform(UInt32(list.count)))
            MusicManager.currentIndex = random
            
            let music = list[random]
            
            self.musicPlayer = MusicPlayer(music: music)
            self.musicPlayer.setDelegate(self)
            
            self.songNameLabel.text = music.title
            self.singerNameLabel.text = music.artist
            
            self.cover.imageLayer.contents = music.artwork?.cgImage ?? #imageLiteral(resourceName: "logo").cgImage
            
            self.controlView.setFavor(music.isFavor)
            
            if shouldPlay {
                self.resumePlay()
            }
            
        } else {
            self.songNameLabel.text = ""
            self.singerNameLabel.text = ""
            
            self.cover.imageLayer.contents = #imageLiteral(resourceName: "logo").cgImage
            
            self.pause()
        }
    }
    
    @objc func pause() {
        self.controlView.pause()  //按钮暂停
        self.cover.stopRotating() //动画暂停
        
        if self.musicPlayer != nil {
            self.musicPlayer.pause()  //播放暂停
        }
    }
    
    @objc func resumePlay() {
        self.musicPlayer.play()
        self.controlView.play()

        self.cover.startRotating()
    }

    @objc func didGetMusicInfo(notice: Notification) {
        if let music = notice.object as? Music , music == MusicManager.currentMusic() {
            self.cover.imageLayer.contents = music.artwork?.cgImage ?? #imageLiteral(resourceName: "logo").cgImage
            self.songNameLabel.text = music.title
            self.singerNameLabel.text = music.artist
        }
        
    }
    
    
    
    @objc func remoteCommandPrevious() {
        prepare(true)
    }
    
    @objc func remoteCommandNext() {
        prepare(true)
    }
}

extension MusicViewController {
    func updateConstraints() {
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(35)
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
        }
        
        controlView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.equalTo(251)
            if UIScreen.main.bounds.size.height <= 568 {
                make.bottom.equalToSuperview().offset(-25)
            } else {
                make.bottom.equalToSuperview().offset(-55)
            }
            make.height.equalTo(58)
        }
        
        songNameLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-100)
            make.top.equalToSuperview().offset(318)
        }
        
        singerNameLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-100)
            make.top.equalToSuperview().offset(338)
        }
    }
}
