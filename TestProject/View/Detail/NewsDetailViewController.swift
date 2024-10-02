//
//  NewsDetailViewController.swift
//  TestProject
//
//  Created by Timur Kadiev on 01.10.2024.
//

import UIKit
import Combine
import SafariServices


class NewsDetailViewController: UIViewController {
    
    private var news: News
    private var cancellables = Set<AnyCancellable>()
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.layer.cornerRadius = 10
        return iv
    }()
    
    private let descriptionLabel: StyledLable = {
        let label = StyledLable(textStyle: .bold)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dateLabel: StyledLable = {
        let label = StyledLable(textStyle: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let readMoreButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Constants.textСontinued, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: Device.iPhone ? 16 : 24, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 5
        button.tintColor = .white
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: Constants.padding, bottom: 0, right: Constants.padding)
        return button
    }()
    
    init(news: News) {
        self.news = news
        super.init(nibName: nil, bundle: nil)
        self.title = news.categoryType.rawValue
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Жизненный цикл
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupViews()
        configureWithNews()
    }
    
    private func setupViews() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        contentView.addSubview(imageView)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(readMoreButton)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.paddingHorizontal),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.paddingHorizontal),
            imageView.heightAnchor.constraint(equalToConstant: ScreenSize.height / 3),
            
            descriptionLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: Constants.paddingVertical),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.paddingHorizontal),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.paddingHorizontal),
            
            readMoreButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: Constants.paddingVertical),
            readMoreButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.paddingHorizontal),
            readMoreButton.heightAnchor.constraint(equalToConstant: 45),
            readMoreButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.paddingVertical),
            
            dateLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: Constants.paddingVertical),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.paddingHorizontal),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.paddingHorizontal),
        ])
        
        readMoreButton.addTarget(self, action: #selector(readMoreTapped), for: .touchUpInside)
        
    }
    
    @objc private func readMoreTapped() {
        guard let url = URL(string: news.fullURL) else { return }
        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true, completion: nil)
    }
    
    private func configureWithNews() {
        descriptionLabel.text = news.description
        dateLabel.text = "Дата публикации: \(formattedDate(from: news.publishedDate))"
        
        if let imageURL = URL(string: news.titleImageURL ?? "") {
            Task {
                if let image = await ImageCacheManager.shared.loadImage(from: imageURL) {
                    await MainActor.run {
                        self.imageView.image = image
                    }
                } else {
                    await MainActor.run {
                        self.imageView.image = nil
                    }
                }
            }
        } else {
            imageView.image = nil
        }
    }
    
    private func formattedDate(from isoDate: String) -> String {
        let formats = [
            "yyyy-MM-dd'T'HH:mm:ss.SSS",
            "yyyy-MM-dd'T'HH:mm:ss"
        ]

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")

        var date: Date? = nil

        for format in formats {
            formatter.dateFormat = format
            if let parsedDate = formatter.date(from: isoDate) {
                date = parsedDate
                break
            }
        }

        if let validDate = date {
            let outputFormatter = DateFormatter()
            outputFormatter.dateStyle = .short
            outputFormatter.timeStyle = .none
            return outputFormatter.string(from: validDate)
        } else {
            print("Не удалось преобразовать дату: \(isoDate)")
            return isoDate
        }
    }

}


