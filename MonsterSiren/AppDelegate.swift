//
//  AppDelegate.swift
//  MonsterSiren
//
//  Created by 周廷叡 on 2021/11/02.
//

import UIKit
import AVFoundation
import SwiftAudioPlayer
import AVKit
import MediaPlayer

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
        
        // イヤホンとかのボタンイベント(リモートコマンドイベント)に対応する
        addRemoteCommandEvent()
        
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
    
    
    // MARK: Remote Command Event
    // URL: https://nackpan.net/blog/2015/09/25/ios-swift-remote-control-event/
    func addRemoteCommandEvent() {
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.togglePlayPauseCommand.addTarget(handler: { [unowned self] commandEvent -> MPRemoteCommandHandlerStatus in
            self.remoteTogglePlayPause(commandEvent)
            return MPRemoteCommandHandlerStatus.success
        })
        commandCenter.playCommand.addTarget(handler: { [unowned self] commandEvent -> MPRemoteCommandHandlerStatus in
            self.remotePlay(commandEvent)
            return MPRemoteCommandHandlerStatus.success
        })
        commandCenter.pauseCommand.addTarget(handler: { [unowned self] commandEvent -> MPRemoteCommandHandlerStatus in
            self.remotePause(commandEvent)
            return MPRemoteCommandHandlerStatus.success
        })
        commandCenter.nextTrackCommand.addTarget(handler: { [unowned self] commandEvent -> MPRemoteCommandHandlerStatus in
            self.remoteNextTrack(commandEvent)
            return MPRemoteCommandHandlerStatus.success
        })
        commandCenter.previousTrackCommand.addTarget(handler: { [unowned self] commandEvent -> MPRemoteCommandHandlerStatus in
            self.remotePrevTrack(commandEvent)
            return MPRemoteCommandHandlerStatus.success
        })
        
        
    }
    
    func remoteTogglePlayPause(_ event: MPRemoteCommandEvent) {
        // イヤホンのセンターボタンを押した時の処理
        print("イヤホンのセンターボタンを押した時の処理")
        // 再生をtoggleする
        SAPlayer.shared.togglePlayAndPause()
    }
    
    func remotePlay(_ event: MPRemoteCommandEvent) {
        // プレイボタンが押された時の処理
        print("プレイボタンが押された時の処理")
    }
    
    func remotePause(_ event: MPRemoteCommandEvent) {
        // ポーズボタンが押された時の処理
        print("ポーズが押された時の処理")
    }
    
    func remoteNextTrack(_ event: MPRemoteCommandEvent) {
        // 「次へ」ボタンが押された時の処理
        print("次の曲へ")
    }
    
    func remotePrevTrack(_ event: MPRemoteCommandEvent) {
        // 「前へ」ボタンが押された時の処理
        print("前の曲へ")
        
    }
}

