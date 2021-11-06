//
//  Extensions.swift
//  Extensions
//
//  Created by p1atdev on 2021/11/03.
//

import UIKit
import SwiftUI

extension UIImage {
    public convenience init(url: String) {
        let url = URL(string: url)
        do {
            let data = try Data(contentsOf: url!)
            self.init(data: data)!
            return
        } catch let err {
            print("Error : \(err.localizedDescription)")
        }
        self.init()
    }
}

extension String
{
    func sizeUsingFont(fontSize: CGFloat, weight: Font.Weight) -> CGSize
    {
        var uiFontWeight = UIFont.Weight.regular
        
        switch weight {
        case Font.Weight.heavy:
            uiFontWeight = UIFont.Weight.heavy
        case Font.Weight.bold:
            uiFontWeight = UIFont.Weight.bold
        case Font.Weight.light:
            uiFontWeight = UIFont.Weight.light
        case Font.Weight.medium:
            uiFontWeight = UIFont.Weight.medium
        case Font.Weight.semibold:
            uiFontWeight = UIFont.Weight.semibold
        case Font.Weight.thin:
            uiFontWeight = UIFont.Weight.thin
        case Font.Weight.ultraLight:
            uiFontWeight = UIFont.Weight.ultraLight
        case Font.Weight.black:
            uiFontWeight = UIFont.Weight.black
        default:
            uiFontWeight = UIFont.Weight.regular
        }
        
        let font = UIFont.systemFont(ofSize: fontSize, weight: uiFontWeight)
        let fontAttributes = [NSAttributedString.Key.font: font]
        return self.size(withAttributes: fontAttributes)
    }
}

extension NSURLRequest {
    static func allowsAnyHTTPSCertificateForHost(host: String) -> Bool {
        return true
    }
}

extension View {
    
    /// 現在のセーフエリアの幅を返すよ
    var safeAreaIntents: UIEdgeInsets {
        let keyWindow = UIApplication.shared.connectedScenes
        
            .filter({$0.activationState == .foregroundActive})
        
            .map({$0 as? UIWindowScene})
        
            .compactMap({$0})
        
            .first?.windows
        
            .filter({$0.isKeyWindow}).first
        
        return (keyWindow?.safeAreaInsets) ?? .init(top: 0, left: 0, bottom: 0, right: 0)
    }
    
}
