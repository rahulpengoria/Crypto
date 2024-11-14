//
//  UIViewExtension.swift
//  Crypto
//
//  Created by Rahul Pengoria on 14/11/24.
//

import UIKit

extension UIView {
    
    private struct LoaderConstants {
        static let loaderViewTag = 999999
    }
    
    /// Shows a full-page loader on the view
    func showLoader() {
        // Check if a loader already exists, avoid adding a duplicate
        guard viewWithTag(LoaderConstants.loaderViewTag) == nil else { return }
        
        // Create a loader view to cover the entire screen
        let loaderView = UIView()
        loaderView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        loaderView.tag = LoaderConstants.loaderViewTag
        loaderView.translatesAutoresizingMaskIntoConstraints = false
        
        // Create an activity indicator
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .white
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.startAnimating()
        
        loaderView.addSubview(activityIndicator)
        
        // Center the activity indicator within the loader view
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: loaderView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: loaderView.centerYAnchor)
        ])
        
        addSubview(loaderView)
        
        // Add constraints to make the loader view fill the parent view
        NSLayoutConstraint.activate([
            loaderView.topAnchor.constraint(equalTo: topAnchor),
            loaderView.bottomAnchor.constraint(equalTo: bottomAnchor),
            loaderView.leadingAnchor.constraint(equalTo: leadingAnchor),
            loaderView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    /// Hides the full-page loader from the view
    func hideLoader() {
        viewWithTag(LoaderConstants.loaderViewTag)?.removeFromSuperview()
    }
}

