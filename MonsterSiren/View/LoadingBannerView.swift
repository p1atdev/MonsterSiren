//
//  LoadingBannerView.swift
//  LoadingBannerView
//
//  Created by 周廷叡 on 2021/11/02.
//

import SwiftUI

struct LoadingBannerView: View {
    @State var opacity = 0.9
    @State var loadOpacity = 1.0
    @State var scale = 1.0
    
    /// 読み込み完了したかどうか
    @Binding var loaded: Bool
    
    /// ウィンドウのサイズ
    var window = UIScreen.main.bounds
    
    
    var body: some View {
        VStack {
            Spacer()
            
            ZStack {
                Rectangle()
                    .foregroundColor(.black)
                    .frame(height: window.height / 8)
                
                Image("loading")
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: window.height / 16, alignment: .center)
                    .opacity(0.9)
                
                Image("loading")
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: window.height / 16, alignment: .center)
                    .scaleEffect(scale)
                    .opacity(loadOpacity)
            }
            .opacity(self.opacity)
            .animation(.linear(duration: 0.5)
                        .delay(0.2)
                        .repeatForever(autoreverses: loaded),
                       value: loadOpacity)
            .animation(.linear(duration: 0.5)
                        .delay(0.2)
                        .repeatForever(autoreverses: loaded),
                       value: scale)
            .onAppear {
                withAnimation {
                    self.loadOpacity = 0.0
                    self.scale = 2.0
                }
            }
        }
        .opacity(loaded ? 0.0 : 0.9)
    }
}
