//
//  URLDynamicImageView.swift
//  MonsterSiren
//
//  Created by 周廷叡 on 2021/11/03.
//

import SwiftUI

struct URLDynamicImageView: View {
    
    @ObservedObject var viewModel: URLImageViewModel
    
    var body: some View {
        if let imageData = self.viewModel.downloadData {
            if let image = UIImage(data: imageData) {
                return Image(uiImage: image).resizable().scaledToFit()
            } else {
                return Image(uiImage: UIImage()).resizable().scaledToFit()
            }
        } else {
            return Image(uiImage: UIImage()).resizable().scaledToFit()
        }
    }
}
