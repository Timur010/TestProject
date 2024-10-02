//
//  NoInternetView.swift
//  TestProject
//
//  Created by Timur Kadiev on 02.10.2024.
//

import UIKit

class NoInternetView: UIView {
    
    var messageLabel: UILabel = {
        let label = UILabel()
        label.text = "Нет интернета"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = UIColor.red.withAlphaComponent(0.9)
        addSubview(messageLabel)
        
        NSLayoutConstraint.activate([
            messageLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            messageLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
        
        layer.cornerRadius = 10
        clipsToBounds = true
    }
}
