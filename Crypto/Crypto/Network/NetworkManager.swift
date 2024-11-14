//
//  NetworkManager.swift
//  Crypto
//
//  Created by Rahul Pengoria on 13/11/24.
//

import Foundation

// Enum for Network Errors
/// An enum to represent various network-related errors.
enum NetworkError: Error, Equatable {
    case invalidUrl
    case invalidResponse
    case noData
    case decodingError
    case emptyDataWithFilteredApplied
    case requestFailed
    case serverError(String)
    
    static func ==(lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
            case (.invalidUrl, .invalidUrl),
                (.invalidResponse, .invalidResponse),
                (.noData, .noData),
                (.decodingError, .decodingError), (.requestFailed, .requestFailed):
                return true
            case let (.serverError(lhsMessage), .serverError(rhsMessage)):
                return lhsMessage == rhsMessage
            default:
                return false
        }
    }
    
}

// NetworkManager for handling network requests
/// A singleton class responsible for making network requests and handling responses.
/// It provides a generic method to handle API requests and parse responses into the expected model.
final class NetworkManager {
    
    static let shared = NetworkManager()
    
    /// The shared singleton instance of NetworkManager.
    private init() {}
    
    /// A generic method for making a network request and decoding the response into the specified model.
    ///
    /// - Parameter urlRequest: The URLRequest representing the network request to be made.
    /// - Returns: A `Result` type containing either the decoded model of type `T` or a `NetworkError`.
    func request<T: Decodable>(with urlRequest: URLRequest) async -> Result<T, Error> {
        
        do {
            // Attempt to fetch the data and response using URLSession
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
            // Check if the server returned a successful response
            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                // If status code is not in the 2xx range, return a server error
                let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                return .failure(NetworkError.serverError(errorMessage))
            }
            
            // Attempt to decode the received data into the expected model
            do {
                let jsonDecoder = JSONDecoder()
                jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase // Handle snake_case keys in JSON
                let decodedResponse = try jsonDecoder.decode(T.self, from: data)
                return .success(decodedResponse)
            } catch {
                // Return a decoding error if the response cannot be decoded
                return .failure(NetworkError.decodingError)
            }
            
        } catch {
            // Handle network errors such as no data or timeout issues
            return .failure(NetworkError.noData)
        }
        
    }
}
