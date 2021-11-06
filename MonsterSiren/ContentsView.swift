//
//  ContentsView.swift
//  ContentsView
//
//  Created by p1atdev on 2021/11/02.
//

import SwiftUI

struct ContentsView: View {
    
    var body: some View {
        RootView()
            .frame(minWidth: 360 , minHeight: 570)
            .environmentObject(PlayerViewModel())
    }
}
