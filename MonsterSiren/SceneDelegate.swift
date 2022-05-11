//
//  SceneDelegate.swift
//  MonsterSiren
//
//  Created by p1atdev on 2021/11/02.
//

import UIKit
import SwiftUI
import AVFoundation
import AVKit
import MediaPlayer
//import SwiftAudioPlayer
import SwiftAudioEx

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    @EnvironmentObject var playerViewModel: PlayerViewModel

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        
        // ContentsViewを定義
        let contentsView = ContentsView().environmentObject(PlayerViewModel())
        
        // SwiftUIを指定する
        window?.rootViewController = UIHostingController(rootView: contentsView)

        // ステータスバーを消す
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        #if targetEnvironment(macCatalyst)
        if let titlebar = windowScene.titlebar {
            titlebar.titleVisibility = .hidden
            titlebar.toolbar = nil
        }
        #endif
        
        // ウィンドウサイズの制限
        // URL: https://stackoverflow.com/questions/57123554/mac-catalyst-minimum-window-size-for-mac-catalyst-app
        UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.forEach { windowScene in
            windowScene.sizeRestrictions?.minimumSize = CGSize(width: 1100, height: 700)
        }
        
        // イヤホンとかのボタンイベント(リモートコマンドイベント)に対応する
        addRemoteCommandEvent()
        
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
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
        print("[*] イヤホンのセンターボタンを押した時の処理")
        // 再生をtoggleする
//        playerViewModel.togglePlayStop()
    }
    
    func remotePlay(_ event: MPRemoteCommandEvent) {
        // プレイボタンが押された時の処理
        print("[*] プレイボタンが押された時の処理")
//        SAPlayer.shared.play()
    }
    
    func remotePause(_ event: MPRemoteCommandEvent) {
        // ポーズボタンが押された時の処理
        print("[*] ポーズが押された時の処理")
//        SAPlayer.shared.pause()
    }
    
    // TODO: ここの曲スキップがうまくいかない
    
    func remoteNextTrack(_ event: MPRemoteCommandEvent) {
        // 「次へ」ボタンが押された時の処理
        print("[*] 次の曲へ")
        
//        playerViewModel.skipForward()
    }
    
    func remotePrevTrack(_ event: MPRemoteCommandEvent) {
        // 「前へ」ボタンが押された時の処理
        print("[*] 前の曲へ")
        
//        playerViewModel.skipBackwards()
    }

}

