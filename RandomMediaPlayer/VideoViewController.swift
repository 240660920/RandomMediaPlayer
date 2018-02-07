//
//  VideoViewController.swift
//  RandomMediaPlayer
//
//  Created by xieran on 2018/2/5.
//  Copyright © 2018年 xieran. All rights reserved.
//

import UIKit
import MediaPlayer
import AVKit

class VideoViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
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
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.black
        label.textAlignment = .center
        view.addSubview(label)
        return label
    }()
    
    lazy var table: UITableView = {
        let t = UITableView(frame: .zero)
        t.delegate = self
        t.dataSource = self
        t.backgroundColor = UIColor.clear
        t.separatorStyle = .none
        blackMask.addSubview(t)
        return t
    }()
    
    var videos = [Video]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        titleLabel.text = "Video"
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(35)
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
        }
        
        view.backgroundColor = yellowBackgroundColor
        
        view.addSubview(blackMask)
        
        table.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        loadVideos()
    }
    
    func loadVideos() {
        let plist = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "VideoDescriptions", ofType: "plist")!)

        
        let paths = Bundle.main.paths(forResourcesOfType: nil, inDirectory: "Videos")
        for bundlePath in paths {
            let asset = AVURLAsset(url: URL(fileURLWithPath: bundlePath))
            let generator = AVAssetImageGenerator(asset: asset)
            
            var actualTime = CMTime(seconds: 0, preferredTimescale: 1)
            do {
                let video = Video()
                
                video.resourcePath = bundlePath
                
                let image = try UIImage(cgImage: generator.copyCGImage(at: CMTime(seconds: 0, preferredTimescale: 1), actualTime: &actualTime))
                video.thumbnailImage = image
                
                let filename = bundlePath.components(separatedBy: "/").last ?? ""
                
                let cm_time = asset.duration
                let seconds = Int(ceil(Double(cm_time.value) / 1000.0))
                let timeString = self.getTimeString(seconds: seconds)
                video.time = timeString
                
                
                if let dic = plist?[filename] as? NSDictionary {
                    if let description = dic["description"] as? String {
                        video.descriptionString = description
                    }

                    if let author = dic["author"] as? String{
                        video.author = author
                    }
                }
                
                videos.append(video)
                
            } catch {
                
            }
        }
        
        table.reloadData()
    }
    
    func getTimeString(seconds: Int) -> String {
        let hour = String(format: "%02ld",seconds / 3600)
        let minute = String(format: "%02ld",((seconds % 3600)/60))
        let second = String(format: "%02ld",seconds % 60)
        if hour == "00" {
            return minute + ":" + second
        }
        return hour + ":" + minute + ":" + second
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Video") as? VideoTableViewCell
        if cell == nil {
            cell = VideoTableViewCell(style: .default, reuseIdentifier: "Video")
            cell?.selectionStyle = .none
        }
        
        let video = self.videos[indexPath.row]
        
        cell?.thumbnailImageView.image = video.thumbnailImage
        cell?.descLabel.text = video.descriptionString
        cell?.timeLabel.text = video.time
        cell?.authorLabel.text = video.author
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let video = self.videos[indexPath.row]
        return VideoTableViewCell.getCellHeight(ofText: video.descriptionString)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let video = self.videos[indexPath.row]
        let controller = AVPlayerViewController()
        controller.player = AVPlayer(url: URL(fileURLWithPath: video.resourcePath))
        self.present(controller, animated: true, completion: {
            controller.player?.play()
        })
        
        NotificationCenter.default.post(name: Notification.Name.AVAudioSessionInterruption, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

class Video {
    var thumbnailImage: UIImage?
    var descriptionString = ""
    var time = "00:00"
    var author = ""
    var resourcePath = ""
}
