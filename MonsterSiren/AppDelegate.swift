//
//  AppDelegate.swift
//  MonsterSiren
//
//  Created by 周廷叡 on 2021/11/02.
//

import UIKit
import AVFoundation
import SwiftAudioPlayer

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // URL: https://qiita.com/kenny_J_7/items/936d91151149868618a8
        /// AVAudioSessionCategory設定
        let session = AVAudioSession.sharedInstance()
        do {
            // CategoryをPlaybackにする
            try session.setCategory(.playback, mode: .default)
        } catch  {
            // 予期しない場合
            fatalError("Category設定失敗")
        }
        
        // session有効化
        do {
            try session.setActive(true)
        } catch {
            // 予期しない場合
            fatalError("Session有効化失敗")
        }
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    // 音声のオフライン再生？
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        SAPlayer.Downloader.setBackgroundCompletionHandler(completionHandler)
    }


}

