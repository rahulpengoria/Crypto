//
//  CryptoListService.swift
//  Crypto
//
//  Created by Rahul Pengoria on 13/11/24.
//

import Foundation

/// A protocol that defines the requirements for fetching cryptocurrency data.
protocol CryptoCoinFetchable {
    func fetchCryptoCoins() async -> Result<[CryptoCoinData], Error>
}

final class CryptoListService: CryptoCoinFetchable {
    
    /// Fetches cryptocurrency data from a remote API.
    
    /// - Returns: A `Result` type containing either:
    ///   - A list of `CryptoCoinData` if the request is successful.
    ///   - A `NetworkError` in case of failure
    func fetchCryptoCoins() async -> Result<[CryptoCoinData], Error> {
        // Construct the URL for the API endpoint
        guard let url = URL(string: "https://37656be98b8f42ae8348e4da3ee3193f.api.mockbin.io/") else {
            // Return a failure if the URL is invalid
            return .failure(NetworkError.invalidUrl)
        }
        
        // Create the URLRequest from the constructed URL
        let request = URLRequest(url: url)
        
        // Use the shared NetworkManager to make the request and return the result
        return await NetworkManager.shared.request(with: request)
    }
    
}
