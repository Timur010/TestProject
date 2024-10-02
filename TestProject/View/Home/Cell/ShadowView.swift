//
//  ShadowView.swift
//  TestProject
//
//  Created by Timur Kadiev on 01.10.2024.
//

import UIKit

class ShadowView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupShadow()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupShadow()
    }
    
    private func setupShadow() {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.25
        self.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.layer.shadowRadius = 5
        self.layer.cornerRadius = 8
        self.backgroundColor = .white
    }
}
