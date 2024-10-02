//
//  HomeViewCell.swift
//  TestProject
//
//  Created by Timur Kadiev on 01.10.2024.
//

import UIKit
import Combine

class HomeViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "HomeViewCell"
    private var cancellables = Set<AnyCancellable>()
    
    private let shadowView: ShadowView = {
        let view = ShadowView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let titleLabel: StyledLable = {
        let label = StyledLable(textStyle: .medium)
        label.numberOfLines = 3
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        return label
    }()
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.layer.cornerRadius = 8
        return iv
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator: UIActivityIndicatorView
        if #available(iOS 13.0, *) {
            indicator = UIActivityIndicatorView(style: .medium)
        } else {
            indicator = UIActivityIndicatorView(style: .gray)
        }
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(shadowView)
        shadowView.addSubview(imageView)
        shadowView.addSubview(titleLabel)
        shadowView.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            shadowView.topAnchor.constraint(equalTo: contentView.topAnchor),
            shadowView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            shadowView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            shadowView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            imageView.topAnchor.constraint(equalTo: shadowView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: shadowView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: shadowView.trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: shadowView.heightAnchor, multiplier: 0.7),
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: Constants.padding),
            titleLabel.leadingAnchor.constraint(equalTo: shadowView.leadingAnchor, constant: Constants.padding),
            titleLabel.trailingAnchor.constraint(equalTo: shadowView.trailingAnchor, constant: -Constants.padding),
            titleLabel.bottomAnchor.constraint(equalTo: shadowView.bottomAnchor, constant: -Constants.padding),
            
            activityIndicator.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: imageView.centerYAnchor)
        ])
    }
    
    
    func configure(with news: News) {
        titleLabel.text = news.title
        imageView.image = nil
        activityIndicator.startAnimating()
        
        if let imageURL = URL(string: news.titleImageURL ?? "") {
            Task {
                await imageView.setImage(from: imageURL, placeholder: nil)
                await MainActor.run {
                    self.activityIndicator.stopAnimating()
                }
            }
        } else {
            imageView.image = nil
            activityIndicator.stopAnimating()
        }
    }
    
    override var isSelected: Bool {
        didSet {
            animateSelection(selected: isSelected)
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            animateSelection(selected: isHighlighted)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        activityIndicator.stopAnimating()
        cancellables.removeAll()
        self.transform = .identity
    }
}

extension HomeViewCell {
    private func animateSelection(selected: Bool) {
        self.layer.removeAllAnimations()
        
        let scale: CGFloat = selected ? 0.95 : 1.0
        let animationOptions: UIView.AnimationOptions = selected ? .curveEaseIn : .curveEaseOut
        
        UIView.animate(withDuration: 0.2,
                       delay: 0,
                       options: animationOptions,
                       animations: {
            self.transform = CGAffineTransform(scaleX: scale, y: scale)
        }, completion: nil)
    }
}
