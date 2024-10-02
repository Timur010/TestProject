//
//  UIImageExtention.swift
//  TestProject
//
//  Created by Timur Kadiev on 01.10.2024.
//

import UIKit

extension UIImageView {
    func setImage(from url: URL, placeholder: UIImage? = nil) async {
        await MainActor.run {
            self.image = placeholder
        }
        if let image = await ImageCacheManager.shared.loadImage(from: url) {
            await MainActor.run {
                UIView.transition(with: self,
                                  duration: 0.3,
                                  options: .transitionCrossDissolve,
                                  animations: {
                    self.image = image
                }, completion: nil)
            }
        } else {
            await MainActor.run {
                self.image = placeholder
            }
        }
    }
}
