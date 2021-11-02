//
//  PlayerView.swift
//  PlayerView
//
//  Created by p1atdev on 2021/11/02.
//

import SwiftUI

struct TabBarView: View {
    
    @ObservedObject var playerViewModel: PlayerViewModel
    
    /// ウィンドウのサイズ
    var window = UIScreen.main.bounds
    
    var body: some View {
        VStack {
            VStack {
                // 他のページへ移るボタン
                LinkButtonView(title: "一覧")
                LinkButtonView(title: "検索")
                LinkButtonView(title: "資料")
            }
//            .frame(minHeight: 180, maxHeight: 360)
            .padding()
            
            Spacer()
            
            // プレイヤー
            PlayerView(playerViewModel: playerViewModel)
        }
    }
}

struct LinkButtonView: View {
    
    var title: String
    
    var body: some View {
        
        Button(action: {
            
        }, label: {
            ZStack {
                Rectangle()
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
                    .shadow(color: .black,
                            radius: 12,
                            x: -4,
                            y: 8)
                
                HStack {
                    Spacer()
                    Image("halftone")
                        .resizable()
                        .aspectRatio(1.0, contentMode: .fit)
                }
                
                Text(title)
                    .font(.custom("HiraMinProN-W6", size: 40))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity,
                           alignment: .leading)
                    .padding()
            }
        })
        
    }
}
