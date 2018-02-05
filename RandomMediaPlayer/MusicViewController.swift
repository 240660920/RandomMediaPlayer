//
//  ViewController.swift
//  RandomMediaPlayer
//
//  Created by xieran on 2018/2/5.
//  Copyright © 2018年 xieran. All rights reserved.
//

import UIKit
import AVFoundation

class MusicViewController: UIViewController {

    var player = AVAudioPlayer()
    
    let cover = MusicCover()

    var musics = [Any]()
    
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
        
        self.tabBarItem.title = "music"
        
        view.backgroundColor = backgroundColor
        
        titleLabel.text = "测试"

        
        view.addSubview(blackMask)
        
        cover.frame = CGRect(x: (blackMask.frame.width - 200) / 2, y: 82, width: 200, height: 200)
        cover.backgroundColor = blackMask.backgroundColor
        blackMask.addSubview(cover)
        

        controlView.playBlock = {(isPlaying) in
            if isPlaying {
                do {
                    let url = self.firstSongPath()
                    try self.player = AVAudioPlayer(contentsOf: url)
                    self.player.play()
                    
                    self.songNameLabel.text = (url.lastPathComponent as NSString).deletingPathExtension
                    
                    let asset = AVURLAsset(url: url)
                    
                    let artists = AVMetadataItem.metadataItems(from: asset.commonMetadata, withKey: AVMetadataKey.commonKeyArtist, keySpace: AVMetadataKeySpace.common)

                    if artists.count > 0 , let artist = artists[0].value as? String {
                        self.singerNameLabel.text = artist
                    }
                } catch {
                    let alert = UIAlertController(title: "播放错误", message: nil, preferredStyle: UIAlertControllerStyle.alert)
                    let action = UIAlertAction(title: "确定", style: UIAlertActionStyle.default, handler: { (action) in
                        alert.dismiss(animated: false, completion: nil)
                    })
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                }
            } else {
                self.player.pause()
            }
        }
        
        controlView.deleteBlock = {() in
            
        }

        controlView.favorBlock = {(isFavor) in
            print(isFavor)
        }
        

        
        updateConstraints()
    }
    
    func firstSongPath() -> URL {
        let paths = Bundle.main.paths(forResourcesOfType: nil, inDirectory: "Songs")
        for (index,path) in paths.enumerated() {
            let url = NSURL(fileURLWithPath: path)
            if let name = url.lastPathComponent{
                print((name as NSString).deletingPathExtension)
            }
        }
        
        if paths.count > 0 {
            return URL(fileURLWithPath: paths[0])
        } else {
            return URL(fileURLWithPath: "")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            make.bottom.equalToSuperview().offset(-55)
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
