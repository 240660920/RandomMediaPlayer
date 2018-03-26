//
//  MusicManager.swift
//  RandomMediaPlayer
//
//  Created by xieran on 2018/2/6.
//  Copyright © 2018年 xieran. All rights reserved.
//

import UIKit
import AVFoundation

let home = NSHomeDirectory() as NSString
let documents = home.appendingPathComponent("Documents") as NSString
let configFileFolder = documents.appendingPathComponent("Musics")
let cacheFolder = documents.appendingPathComponent("Cache")

let songsBundlePath = Bundle.main.paths(forResourcesOfType: nil, inDirectory: "Songs")

class MusicManager {
    
    static var listType = MusicListType.kRecommend
    static var recommedArr = [Music]()
    static var likeArr = [Music]()
    static var currentIndex = 0
    
    static func initializeData() {
        if !FileManager.default.fileExists(atPath: configFileFolder) {
            do {
                try FileManager.default.createDirectory(atPath: configFileFolder, withIntermediateDirectories: true, attributes: nil)
            } catch {
                
            }
        }
        
        if !FileManager.default.fileExists(atPath: cacheFolder) {
            try? FileManager.default.createDirectory(atPath: cacheFolder, withIntermediateDirectories: true, attributes: nil)
        }

        let data = try? Data(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "MusicLinks", ofType: "txt")!))
        let str = String(data: data ?? Data(), encoding: String.Encoding.ascii)
        let links = str?.components(separatedBy: "\n") ?? [String]()
        
        var arr = [Music]()
        
        for url in links {
            let _url = url.replacingOccurrences(of: "\r", with: "")
            
            let fullname = (_url as NSString).lastPathComponent
            let name = fullname.components(separatedBy: ".").first ?? ""
            let destPath = (configFileFolder as NSString).appendingPathComponent(name)
            
            let music: Music!
            
            if !FileManager.default.fileExists(atPath: destPath) {
                
                music = Music()
                music.fullName = fullname
                music.name = name
                music.fileExtension = (fullname as NSString).pathExtension
                music.urlString = _url
                
                NSKeyedArchiver.archiveRootObject(music, toFile: destPath)
                
                if !music.isDeleted {
                    arr.append(music)
                }
            } else {
                music = NSKeyedUnarchiver.unarchiveObject(withFile: destPath) as! Music
                if !music.isDeleted {
                    arr.append(music)
                }
            }
        }
        
        recommedArr = arr
        
        likeArr = arr.filter({ (music) -> Bool in
            return music.isFavor == true
        })
    }
    
    static func list(ofType type: MusicListType) -> [Music] {
        return type == .kRecommend ? MusicManager.recommedArr : MusicManager.likeArr
    }
    
    static func like(_ music: Music) {
        music.isFavor = !music.isFavor
        
        if music.isFavor {
            MusicManager.likeArr.append(music)
            
        } else {
            if let index = MusicManager.likeArr.index(of: music) {
                MusicManager.likeArr.remove(at: index)
            }
        }
        
        music.save()
    }
    
    static func currentMusic() -> Music? {
        let list = self.list(ofType: self.listType)
        if list.count > 0 , currentIndex < list.count {
            return list[currentIndex]
        } else {
            return nil
        }
    }
    
    static func delete(_ music: Music) {
        music.isDeleted = true
        
        music.save()
        
        if let index = self.recommedArr.index(of: music) {
            self.recommedArr.remove(at: index)
        }
        
        if let index = self.likeArr.index(of: music) {
            self.likeArr.remove(at: index)
        }
    }
    
    static func download(_ music: Music) {
        let destPath = (cacheFolder as NSString).appendingPathComponent(music.fullName)
        guard !FileManager.default.fileExists(atPath: destPath) , !music.urlString.isEmpty else {
            return
        }
        
        let urlSession = URLSession.shared
        let dataTask = urlSession.downloadTask(with: URL(string: music.urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)!) { (url, response, error) in
            
            try? FileManager.default.moveItem(at: url!, to: URL(fileURLWithPath: destPath))
            
            ////////
            let asset = AVURLAsset(url: URL(fileURLWithPath: destPath))
            
            let artworks = AVMetadataItem.metadataItems(from: asset.commonMetadata, withKey: AVMetadataKey.commonKeyArtwork, keySpace: AVMetadataKeySpace.common)
            
            let titles = AVMetadataItem.metadataItems(from: asset.commonMetadata, withKey: AVMetadataKey.commonKeyTitle, keySpace: AVMetadataKeySpace.common)
            
            let artists = AVMetadataItem.metadataItems(from: asset.commonMetadata, withKey: AVMetadataKey.commonKeyArtist, keySpace: AVMetadataKeySpace.common)
            
            if titles.count > 0 {
                music.title = titles[0].value as? String ?? ""
            }
            
            if artists.count > 0 {
                music.artist = artists[0].value as? String ?? ""
            }
            if artworks.count > 0 {
                let data = artworks[0].dataValue ?? Data()
                music.artwork = UIImage(data: data)
            }

            music.save()
            
            
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name.init("didGetMusicInfo"), object: music)
            }
        }
        
        dataTask.resume()
    }
}

class Music: NSObject,NSCoding {

    
    var name = ""
    var fullName = ""
    var artist = "loading..."
    var title = "loading..."
    var fileExtension = ""
    var isFavor = false
    var isDeleted = false
    var artwork: UIImage? = nil
    var urlString = ""
    
    override init() {
        
    }
    
    required init?(coder aDecoder: NSCoder){
        name = aDecoder.decodeObject(forKey: "name") as! String
        fullName = aDecoder.decodeObject(forKey: "fullName") as! String
        artist = aDecoder.decodeObject(forKey: "artist") as! String
        fileExtension = aDecoder.decodeObject(forKey: "fileExtension") as! String
        isFavor = aDecoder.decodeBool(forKey: "isFavor")
        isDeleted = aDecoder.decodeBool(forKey: "isDeleted")
        artwork = aDecoder.decodeObject(forKey: "artwork") as? UIImage
        urlString = aDecoder.decodeObject(forKey: "urlString") as! String
        title = aDecoder.decodeObject(forKey: "title") as! String

        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        aCoder.encode(fullName, forKey: "fullName")
        aCoder.encode(artist, forKey: "artist")
        aCoder.encode(fileExtension, forKey: "fileExtension")
        aCoder.encode(isFavor, forKey: "isFavor")
        aCoder.encode(isDeleted, forKey: "isDeleted")
        aCoder.encode(artwork, forKey: "artwork")
        aCoder.encode(urlString, forKey: "urlString")
        aCoder.encode(title, forKey: "title")
    }
    
    func save() {
        let path = (configFileFolder as NSString).appendingPathComponent(self.name)
        NSKeyedArchiver.archiveRootObject(self, toFile: path)
    }
    
    func cachePath() -> String {
        return (cacheFolder as NSString).appendingPathComponent(self.fullName)
    }
}
