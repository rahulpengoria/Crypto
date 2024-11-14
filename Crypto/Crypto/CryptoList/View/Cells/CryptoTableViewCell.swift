//
//  CryptoTableViewCell.swift
//  Crypto
//
//  Created by Rahul Pengoria on 13/11/24.
//

import UIKit

final class CryptoTableViewCell: UITableViewCell {
    
    // Title label
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor.primaryTextColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Subtitle label
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = UIColor.secondaryTextColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Badge ImageView
    private let badgeImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "New"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // crypto ImageView
    private let cryptoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "bitcoinsign.circle.fill")
        return imageView
    }()
    
    // Initialize the cell with custom subviews
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Setup subviews and constraints
    private func setup() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(badgeImageView)
        contentView.addSubview(cryptoImageView)
        
        NSLayoutConstraint.activate([
            // Title label constraints
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            
            // Subtitle label constraints
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            // Crypto image view constraints
            cryptoImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cryptoImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            cryptoImageView.widthAnchor.constraint(equalToConstant: 24),
            cryptoImageView.heightAnchor.constraint(equalToConstant: 24),
            
            // Badge image view constraints
            badgeImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            badgeImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            badgeImageView.widthAnchor.constraint(equalToConstant: 30),
            badgeImageView.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    // Configure the cell conten
    func configure(with crypto: CryptoCoinData) {
        titleLabel.text = crypto.name
        subtitleLabel.text = crypto.symbol
        setCryptoCoinImage(for: crypto.type,
                           isCryptoActive: crypto.isActive)
        setNewType(with: crypto)
    }
    
    private func setCryptoCoinImage(for type: CryptoCoinData.CryptoType,
                                    isCryptoActive: Bool) {
        guard type != .inActive, isCryptoActive else {
            cryptoImageView.image = UIImage.inActiveCoin
            return
        }
        
        switch type {
            case .coin:
                cryptoImageView.image = UIImage.cryptoCoin
            case .token:
                cryptoImageView.image = UIImage.cryptoToken
            case .inActive:
                cryptoImageView.image = UIImage.inActiveCoin
                
        }
    }
    
    private func setNewType(with crypto: CryptoCoinData) {
        if crypto.isNew {
            badgeImageView.isHidden = false
        } else {
            badgeImageView.isHidden = true
        }
    }
    
}

