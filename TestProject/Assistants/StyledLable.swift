//
//  FontExtention.swift
//  TestProject
//
//  Created by Timur Kadiev on 02.10.2024.
//

import UIKit

final class StyledLable: UILabel {
    
    enum TextStyled {
        case medium, bold, regular
        
        var font: UIFont {
            let isPad = UIDevice.current.userInterfaceIdiom == .pad
            switch self {
            case .medium:
                let fontSize: CGFloat = isPad ? 18: 12
                return UIFont.systemFont(ofSize: fontSize, weight: .medium)
            case .bold:
                let fontSize: CGFloat = isPad ? 20: 15
                return UIFont.systemFont(ofSize: fontSize, weight: .bold)
            case .regular:
                let fontSize: CGFloat = isPad ? 15: 10
                return UIFont.systemFont(ofSize: fontSize, weight: .regular)
            }
        }
        
        var color: UIColor {
            switch self {
            case .medium:
                return .black
            case .bold:
                return .black
            case .regular:
                return . gray
            }
        }
    }
    
    init(textStyle: TextStyled) {
        super.init(frame: .zero)
        font = textStyle.font
        textColor = textStyle.color
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
