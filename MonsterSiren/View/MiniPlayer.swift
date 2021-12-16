//
//  MiniPlayer.swift
//  MonsterSiren
//
//  Created by p1atdev on 2021/11/06.
//

import SwiftUI

struct MiniPlayer: View {
    
    
    @EnvironmentObject var playerViewModel: PlayerViewModel
    
    @State private var coverImage: UIImage = UIImage(named: "disk")!
    
    @State private var backgroundColor: Color = .init(white: 0.15)
    
    @State private var playerShouldShow: Bool = false
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack(spacing: 0) {
                
                HStack(alignment: .center) {
                    if let url = playerViewModel.currentAlbum?.coverUrl {
                        URLDynamicImageView(viewModel: .init(url: url))
                            .scaledToFit()
                            .cornerRadius(2)
                            .shadow(color: .black.opacity(0.5),
                                    radius: 8,
                                    x: -2,
                                    y: 2)
                            .padding(.leading, 8)
                            .padding(.top, 6)
                            .padding(.bottom, 2)
                    } else {
                        Image("disk")
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(2)
                            .shadow(color: .black.opacity(0.5),
                                    radius: 8,
                                    x: -2,
                                    y: 2)
                            .padding(.leading, 8)
                            .padding(.top, 6)
                            .padding(.bottom, 2)
                    }
                    
                    VStack(alignment: .leading) {
                        Text(playerViewModel.currentSong?.name ?? "No data")
                            .font(.title2)
                        
                        
                        Text(playerViewModel.currentSong?.artists.joined(separator: ", ")
                             ?? "No data")
                            .font(.caption)
                            .opacity(0.8)
                        
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        
                        // 切り替え
                        playerViewModel.togglePlayStop()
                        
                    }, label: {
                        
                        Image(systemName: playerViewModel.isPlaying ? "pause.fill" : "play.fill")
                            .font(.title2)
                        
                    })
                        .frame(width: 64)
                        .buttonStyle(PlainButtonStyle())
                    
                    
                }
                
                GeometryReader { geometry in
                    Rectangle()
                        .foregroundColor(Color.gray)
                    
                    Rectangle()
                        .foregroundColor(.white)
                        .frame(width: geometry.size.width * playerViewModel.elapsedTime / playerViewModel.duration )
                }
                .frame(height: 2)
                .padding(.horizontal)
                .padding(.vertical, 2)
                
            }
            .background(backgroundColor)
            .frame(height: 68)
            .cornerRadius(6)
            .shadow(color: .black.opacity(0.4), radius: 12, x: -4, y: 8)
            .padding(.horizontal, 8)
            .padding(.bottom, safeAreaIntents.bottom + 32)
            .onTapGesture {
                playerShouldShow.toggle()
            }
        }
        
        .sheet(isPresented: $playerShouldShow) {
            VStack {
                Spacer()
                PlayerView()
                    .padding(.horizontal, 32)
            }
            .background(
                Image("background")
                    .resizable()
                    .ignoresSafeArea()
            )
        }
        
        
    }
}
