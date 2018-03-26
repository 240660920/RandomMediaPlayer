//
//  AppDelegate.swift
//  RandomMediaPlayer
//
//  Created by xieran on 2018/2/5.
//  Copyright © 2018年 xieran. All rights reserved.
//

import UIKit
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        let tabbarController = TabbarController()
        tabbarController.tabBar.isTranslucent = false
        tabbarController.tabBar.barTintColor = yellowBackgroundColor
        tabbarController.tabBar.tintColor = UIColor.black
        
        let musicController = MusicViewController()
        musicController.tabBarItem.title = "Music"
        musicController.tabBarItem.setTitleTextAttributes([NSAttributedStringKey.font : UIFont.systemFont(ofSize: 15) , NSAttributedStringKey.foregroundColor : UIColor(red: 0x1c/255.0, green: 0x1c/255.0, blue: 0x1c/255.0, alpha: 1)], for: .selected)
        musicController.tabBarItem.setTitleTextAttributes([NSAttributedStringKey.font : UIFont.systemFont(ofSize: 15) , NSAttributedStringKey.foregroundColor : UIColor(white: 0, alpha: 0.5)], for: .normal)
        musicController.tabBarItem.image = #imageLiteral(resourceName: "music_normal").withRenderingMode(.alwaysOriginal)
        musicController.tabBarItem.selectedImage = #imageLiteral(resourceName: "music_selected").withRenderingMode(.alwaysOriginal)
        musicController.tabBarItem.titlePositionAdjustment = UIOffsetMake(35, -20)
        musicController.tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 70)

        let videoController = VideoViewController()
        videoController.tabBarItem.title = "Video"
        videoController.tabBarItem.setTitleTextAttributes([NSAttributedStringKey.font : UIFont.systemFont(ofSize: 15) , NSAttributedStringKey.foregroundColor : UIColor(red: 0x1c/255.0, green: 0x1c/255.0, blue: 0x1c/255.0, alpha: 1)], for: .selected)
        videoController.tabBarItem.setTitleTextAttributes([NSAttributedStringKey.font : UIFont.systemFont(ofSize: 15) , NSAttributedStringKey.foregroundColor : UIColor(white: 0, alpha: 0.5)], for: .normal)
        videoController.tabBarItem.image = #imageLiteral(resourceName: "video_normal").withRenderingMode(.alwaysOriginal)
        videoController.tabBarItem.selectedImage = #imageLiteral(resourceName: "video_selected").withRenderingMode(.alwaysOriginal)
        videoController.tabBarItem.titlePositionAdjustment = UIOffsetMake(0, -20)
        videoController.tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 70)
        
        tabbarController.viewControllers = [musicController , videoController]
        
        self.window?.rootViewController = tabbarController
        
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setActive(true)
            try session.setCategory(AVAudioSessionCategoryPlayback)
        } catch {
            
        }
        
        UIApplication.shared.beginReceivingRemoteControlEvents()
        
        TalkingData.sessionStarted("E18928AAC5AF4F50A3BADFF3DFAEA958", withChannelId: "App Store")
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

