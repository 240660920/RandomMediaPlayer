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
        
        var arr = [Music]()
        
        for musicBundlePath in songsBundlePath {
            let musicFullName = URL(fileURLWithPath: musicBundlePath).lastPathComponent as NSString
            let musicName = musicFullName.deletingPathExtension
            let destPath = (configFileFolder as NSString).appendingPathComponent(musicName)
            
            if !FileManager.default.fileExists(atPath: destPath) {
                let asset = AVURLAsset(url: URL(fileURLWithPath: musicBundlePath))
                
                let artworks = AVMetadataItem.metadataItems(from: asset.commonMetadata, withKey: AVMetadataKey.commonKeyArtwork, keySpace: AVMetadataKeySpace.common)

                
                let artists = AVMetadataItem.metadataItems(from: asset.commonMetadata, withKey: AVMetadataKey.commonKeyArtist, keySpace: AVMetadataKeySpace.common)
                
                let music = Music()
                if artists.count > 0 {
                    music.artist = artists[0].value as? String ?? ""
                }
                if artworks.count > 0 {
                    let data = artworks[0].dataValue ?? Data()
                    music.artwork = UIImage(data: data)
                }
                music.name = musicName
                music.fullName = musicFullName as String
                music.fileExtension = (music.fullName as NSString).pathExtension
                
                NSKeyedArchiver.archiveRootObject(music, toFile: destPath)
                
                if !music.isDeleted {
                    arr.append(music)
                }
            } else {
                let music = NSKeyedUnarchiver.unarchiveObject(withFile: destPath) as! Music
                if !music.isDeleted {
                    arr.append(music)
                }
            }
        }
        
        recommedArr = arr.filter({ (music) -> Bool in
            return music.isFavor == false
        })
        
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
            if let index = MusicManager.recommedArr.index(of: music) {
                MusicManager.recommedArr.remove(at: index)
            }
            
            MusicManager.likeArr.append(music)
            
        } else {
            if let index = MusicManager.likeArr.index(of: music) {
                MusicManager.likeArr.remove(at: index)
            }
            
            MusicManager.recommedArr.append(music)
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
}

class Music: NSObject,NSCoding {

    
    var name = ""
    var fullName = ""
    var artist = ""
    var fileExtension = ""
    var isFavor = false
    var isDeleted = false
    var artwork: UIImage? = nil
    
    override init() {
        
    }
    
    required init?(coder aDecoder: NSCoder){
        name = aDecoder.decodeObject(forKey: "name") as! String
        artist = aDecoder.decodeObject(forKey: "artist") as! String
        fileExtension = aDecoder.decodeObject(forKey: "fileExtension") as! String
        isFavor = aDecoder.decodeBool(forKey: "isFavor")
        isDeleted = aDecoder.decodeBool(forKey: "isDeleted")
        artwork = aDecoder.decodeObject(forKey: "artwork") as? UIImage

        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        aCoder.encode(artist, forKey: "artist")
        aCoder.encode(fileExtension, forKey: "fileExtension")
        aCoder.encode(isFavor, forKey: "isFavor")
        aCoder.encode(isDeleted, forKey: "isDeleted")
        aCoder.encode(artwork, forKey: "artwork")
    }
    
    func save() {
        let path = (configFileFolder as NSString).appendingPathComponent(self.name)
        NSKeyedArchiver.archiveRootObject(self, toFile: path)
    }
    
    func resourcePath() -> String {
        return Bundle.main.path(forResource: self.name, ofType: self.fileExtension, inDirectory: "Songs") ?? ""
    }
}
