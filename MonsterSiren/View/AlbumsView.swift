//
//  MainView.swift
//  MainView
//
//  Created by p1atdev on 2021/11/02.
//

// アルバム一覧を取得して表示する画面

import SwiftUI

struct AlbumsView: View {
    /// アルバムのデータ
    @StateObject var albumsModel = AlbumsViewModel()
    
    /// アルバムが読み込まれたかどうか
    @Binding var loaded: Bool
    
    /// 遷移するアルバム
    @State var albumToPresent: AlbumDetail?
    
    /// プレーヤーのやつ
    @EnvironmentObject var playerViewModel: PlayerViewModel
    
    /// ウィンドウのサイズ
    var window = UIScreen.main.bounds
    
    /// アルバムの列の数
    let columns: [GridItem] = [GridItem(.adaptive(minimum: 170, maximum: 300))]
    
    var body: some View {
        ZStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(albumsModel.albums ?? [], id: \.id) { album in
                        Button(action: {
                            withAnimation {
                                albumToPresent = album
                            }
                        }, label: {
                            URLImageView(url: album.coverUrl)
                                .scaledToFit()
                        })
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, safeAreaIntents.top)
                .padding(.bottom, safeAreaIntents.bottom + 16)
            }
            .opacity(albumToPresent != nil || playerViewModel.shouldShowLyrics ? 0.0 : 1.0)
            .task {
                if albumsModel.albums == nil {
                    let status = await albumsModel.fetch()
                    
                    withAnimation(.linear(duration: 0.3).delay(0.5)) {
                        loaded = status
                    }
                }
            }
            
            if albumToPresent != nil {
                AlbumDetailView(album: $albumToPresent,
                                loaded: $loaded)
                    .transition(.move(edge: .trailing))
                    .zIndex(30)
            }
            
            if playerViewModel.shouldShowLyrics && window.width > 750 {
                // 歌詞
                LyricsView()
                    .transition(.move(edge: .trailing))
                    .zIndex(60)
            }
        }
    }
}

struct AlbumsView_Preview: PreviewProvider {
    static var previews: some View {
        if #available(iOS 15.0, *) {
            AlbumsView(loaded: Binding.constant(false))
                .background(
                    Image("background")
                        .resizable()
                )
                .ignoresSafeArea()
                .environmentObject(PlayerViewModel())
                .previewInterfaceOrientation(.landscapeLeft)
        }
    }
}
