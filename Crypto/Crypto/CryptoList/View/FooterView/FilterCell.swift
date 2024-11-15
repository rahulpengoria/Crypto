//
//  FilterCell.swift
//  Crypto
//
//  Created by Rahul Pengoria on 15/11/24.
//

import UIKit

final class FilterCell: UICollectionViewCell {
    
    static let reuseIdentifier = "FilterCell"
    
    private let filterLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16)
        label.layer.cornerRadius = 15
        label.layer.masksToBounds = true
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(filterLabel)
        filterLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            filterLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            filterLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            filterLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            filterLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with title: String, isSelected: Bool) {
        let text = "\(isSelected ? " ✓ " : "")\(title)"
        filterLabel.text = text
        filterLabel.backgroundColor = isSelected ? UIColor.secondaryBackgroundColor : UIColor.systemGray5
        filterLabel.textColor = UIColor.primaryTextColor
    }
}
