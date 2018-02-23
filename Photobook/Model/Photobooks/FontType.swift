//
//  FontType.swift
//  Photobook
//
//  Created by Jaime Landazuri on 01/02/2018.
//  Copyright © 2018 Kite.ly. All rights reserved.
//

import Foundation

@objc enum FontType: Int, Codable {
    case plain, classic, solid
    
    private func fontWithSize(_ size: CGFloat) -> UIFont {
        let name: String
        switch self {
        case .plain: name = "OpenSans-Regular"
        case .classic: name = "Lora-Regular"
        case .solid: name = "Montserrat-Bold"
        }
        return UIFont(name: name, size: size)!
    }
    
    private func paragraphStyle(isSpineText: Bool) -> NSParagraphStyle {
        let paragraphStyle = NSMutableParagraphStyle()

        switch self {
        case .plain: paragraphStyle.lineHeightMultiple = 1.25
        case .classic: paragraphStyle.lineHeightMultiple = 1.27
        case .solid: paragraphStyle.lineHeightMultiple = 1.23
        }
        
        if isSpineText {
            paragraphStyle.alignment = .center
        }

        return paragraphStyle.copy() as! NSParagraphStyle
    }
    
    private func photobookFontSize(isSpineText: Bool) -> CGFloat {
        switch self {
        case .plain: return 8.0
        case .classic: return 11.0
        case .solid: return 13.0
        }
    }
    
    func typingAttributes(fontSize: CGFloat, fontColor: UIColor, isSpineText: Bool = false) -> [String: Any] {
        let paragraphStyle = self.paragraphStyle(isSpineText: isSpineText)
        let font = fontWithSize(fontSize)
        return [ NSAttributedStringKey.font.rawValue: font, NSAttributedStringKey.foregroundColor.rawValue: fontColor, NSAttributedStringKey.paragraphStyle.rawValue: paragraphStyle ]
    }
    
    func attributedText(with text: String!, fontSize: CGFloat, fontColor: UIColor, isSpineText: Bool = false) -> NSAttributedString {
        let paragraphStyle = self.paragraphStyle(isSpineText: isSpineText)
        let font = fontWithSize(fontSize)
        
        let attributes: [NSAttributedStringKey: Any] = [ NSAttributedStringKey.font: font, NSAttributedStringKey.foregroundColor: fontColor, NSAttributedStringKey.paragraphStyle: paragraphStyle]
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    func sizeForScreenHeight(_ screenHeight: CGFloat, isSpineText: Bool = false) -> CGFloat {
        let photobookToOnScreenScale = screenHeight / ProductManager.shared.product!.pageHeight
        return photobookFontSize(isSpineText: isSpineText) * photobookToOnScreenScale
    }
}
