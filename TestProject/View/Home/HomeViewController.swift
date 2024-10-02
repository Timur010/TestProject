//
//  ViewController.swift
//  TestProject
//
//  Created by Timur Kadiev on 28.09.2024.
//
import UIKit
import Combine
import Network

class HomeViewController: UIViewController {

    private var viewModel: HomeViewModel!
    private var noInternetView: NoInternetView!
    private var collectionView: UICollectionView!
    private var noInternetViewBottomConstraint: NSLayoutConstraint!
    private let monitor = NWPathMonitor()
    private var cancellables = Set<AnyCancellable>()
    
    private let monitorQueue = DispatchQueue(label: "Monitor")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.title = "Новости"
        view.backgroundColor = .white
        setupCollectionView()
        startNetworkMonitoring()
        setupNoInternetView()
        viewModel = HomeViewModel(service: NewsServices())
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            resetVisibleCells()
    }
    
    deinit {
        stopNetworkMonitoring()
    }
    
    private func setupCollectionView() {
        let layout = createCompositionalLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(HomeViewCell.self, forCellWithReuseIdentifier: HomeViewCell.reuseIdentifier)
        
        collectionView.allowsSelection = true
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupNoInternetView() {
        noInternetView = NoInternetView()
        noInternetView.translatesAutoresizingMaskIntoConstraints = false
        noInternetView.isHidden = true
        view.addSubview(noInternetView)
        
        noInternetViewBottomConstraint = noInternetView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 100)
        noInternetViewBottomConstraint.isActive = true
        
        NSLayoutConstraint.activate([
            noInternetView.heightAnchor.constraint(equalToConstant: 50),
            noInternetView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.paddingOnAlert),
            noInternetView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.paddingOnAlert)
        ])
    }

    private func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
        let numberOfColumns = getNumberOfColumns()
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: Constants.paddingItems, leading: Constants.paddingItems , bottom: Constants.paddingItems , trailing: Constants.paddingItems)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(250)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: numberOfColumns)

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 10
        section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)

        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private func getNumberOfColumns() -> Int {
        let deviceType = UIDevice.current.userInterfaceIdiom
        let screenWidth = UIScreen.main.bounds.width
        if deviceType == .phone{
            return 2
        } else if screenWidth >= 1024 {
            return 4
        } else {
            return 3
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in
            self.collectionView.setCollectionViewLayout(self.createCompositionalLayout(), animated: true)
        }, completion: nil)
    }
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.news.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeViewCell.reuseIdentifier, for: indexPath) as? HomeViewCell else {
            fatalError("Не удалось dequeuer ячейку HomeViewCell")
        }
        
        let newsItem = viewModel.news[indexPath.item]
        
        cell.configure(with: newsItem)
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedNews = viewModel.news[indexPath.item]
        
        let detailVC = NewsDetailViewController(news: selectedNews)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

extension HomeViewController {
    
    private func bindViewModel() {
        viewModel.$news
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.collectionView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    private func resetVisibleCells() {
        for cell in collectionView.visibleCells {
            UIView.animate(withDuration: 0.5) {
                cell.transform = CGAffineTransform.identity
            }
        }
    }
    
    private func showNoInternetView() {
        guard noInternetView.isHidden else { return }
        noInternetView.isHidden = false
        noInternetViewBottomConstraint.constant = -10
        
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        }) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.hideNoInternetView()
            }
        }
    }
    
    private func hideNoInternetView() {
        guard !noInternetView.isHidden else { return }
        noInternetViewBottomConstraint.constant = 400
        
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        }) { _ in
            self.noInternetView.isHidden = true
        }
    }
    
    private func startNetworkMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                if path.status == .satisfied {
                    self?.hideNoInternetView()
                } else {
                    self?.showNoInternetView()
                }
            }
        }
        monitor.start(queue: monitorQueue)
    }
    
    private func stopNetworkMonitoring() {
        monitor.cancel()
    }
}
