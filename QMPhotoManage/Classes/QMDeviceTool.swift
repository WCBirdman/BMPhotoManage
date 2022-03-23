//
//  QMDeviceTool.swift
//  QMEnglish
//
//  Created by xmly on 2022/3/22.
//

import UIKit

/// 判断是否是全面屏
public var isiPhoneX: Bool {
    if #available(iOS 11, *) {
          guard let w = UIApplication.shared.delegate?.window, let unwrapedWindow = w else {
              return false
          }

          if unwrapedWindow.safeAreaInsets.left > 0 || unwrapedWindow.safeAreaInsets.bottom > 0 {
              return true
          }
    }
    return false
}
public let is_iPad: Bool = ((UI_USER_INTERFACE_IDIOM() == .pad))
public let qm_screen_W = UIScreen.main.bounds.width
public let qm_screen_H = UIScreen.main.bounds.height
public let qm_font_scale: CGFloat = is_iPad ? 1.5 : 1.0
public let qm_whole_scale: CGFloat = is_iPad ? 1.5 : qm_screen_W / 375.0
public let qm_iPad_scale: CGFloat = is_iPad ? 1.5 : 1.0
public let qm_status_H: CGFloat = isiPhoneX ?  44.0 : 20.0
public let qm_indicator_H: CGFloat = isiPhoneX ? 34.0 : 0

public extension UIColor {
    
    /// 十六进制字符串转UIColor
    /// - Parameter hexString:十六进制字符串
    convenience init(hexString: String, specificAlpha: CGFloat? = nil) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let alpha, red, green, blue: UInt32
        switch hex.count {
        case 3:
          (alpha, red, green, blue) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
          (alpha, red, green, blue) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
          (alpha, red, green, blue) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
              (alpha, red, green, blue) = (1, 1, 1, 0)
        }
        self.init(red: CGFloat(red) / 255, green: CGFloat(green) / 255, blue: CGFloat(blue) / 255, alpha: specificAlpha ?? (CGFloat(alpha) / 255))
    }
    
}
