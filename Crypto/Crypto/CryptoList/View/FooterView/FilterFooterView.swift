//
//  FilterFooterView.swift
//  Crypto
//
//  Created by Rahul Pengoria on 15/11/24.
//

import UIKit
import Combine

final class FilterFooterView: UIView {
    
    private let filters: [CryptoListingViewModel.CryptoFilter] = CryptoListingViewModel.CryptoFilter.allCases
    private var selectedFilters: Set<CryptoListingViewModel.CryptoFilter> = []
    let filterUpdates = PassthroughSubject<Set<CryptoListingViewModel.CryptoFilter>, Never>()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(FilterCell.self, forCellWithReuseIdentifier: FilterCell.reuseIdentifier)
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.footerBackgroundColor
        setupCollectionView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCollectionView() {
        addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            collectionView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 12),
            collectionView.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func updateSelectedFilters() {
        filterUpdates.send(selectedFilters)
    }
}

// MARK: - UICollectionViewDataSource
extension FilterFooterView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterCell.reuseIdentifier, for: indexPath) as! FilterCell
        let filter = filters[indexPath.row]
        cell.configure(with: filter.filterText, isSelected: selectedFilters.contains(filter))
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension FilterFooterView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let filter = filters[indexPath.row]
        if selectedFilters.contains(filter) {
            selectedFilters.remove(filter)
        } else {
            selectedFilters.insert(filter)
        }
        collectionView.reloadItems(at: [indexPath])
        updateSelectedFilters()
    }
}

//MARK: UICollectionViewDelegateFlowLayout
extension FilterFooterView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let filter = filters[indexPath.row]
        let labelText = " ✓ \(filter.filterText)"
        let font = UIFont.systemFont(ofSize: 16)
        let textWidth = labelText.width(withFont: font)
        let cellWidth = textWidth + 12
        let cellHeight: CGFloat = 30
        return CGSize(width: cellWidth, height: cellHeight)
    }
}

