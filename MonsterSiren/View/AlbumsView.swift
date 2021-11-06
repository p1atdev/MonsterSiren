//
//  MainView.swift
//  MainView
//
//  Created by 周廷叡 on 2021/11/02.
//

// アルバム一覧を取得して表示する画面

import SwiftUI

struct AlbumsView: View {
    /// アルバムのデータ
    @StateObject var albumsModel = AlbumsViewModel()
    /// アルバムが読み込まれたかどうか
    @Binding var loaded: Bool
    
    /// 遷移するアルバム
    @State var albumToPresent: Album?
    
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
                            URLImageView(viewModel: .init(url: album.coverUrl))
                                .aspectRatio(1, contentMode: .fit)
                        })
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, safeAreaIntents.top)
                .padding(.bottom, safeAreaIntents.bottom)
            }
            .opacity(albumToPresent == nil ? 1.0 : 0.0)
            .onAppear {
                if albumsModel.albums == nil {
                    DispatchQueue.global().async {
                        albumsModel.fetch() { status in
                            withAnimation(.linear(duration: 0.3).delay(0.5)) {
                                loaded = status
                            }
                        }
                    }
                }
            }
            
            if albumToPresent != nil {
                AlbumDetailView(album: $albumToPresent,
                                loaded: $loaded)
                    .transition(.move(edge: .trailing))
            }
        }
    }
}
