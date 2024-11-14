//
//  Crypto.swift
//  Crypto
//
//  Created by Rahul Pengoria on 13/11/24.
//

import Foundation

/// Api response data model
struct CryptoCoinData: Decodable, Equatable {
    
    enum CryptoType: String, Decodable, Equatable {
        case coin = "coin"
        case token = "token"
        case inActive = "inActive"
        
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let string = try container.decode(String.self)
            self = CryptoType(rawValue: string) ?? .inActive
        }
    }
    
    let name: String
    let symbol: String
    let type: CryptoType
    let isActive: Bool
    let isNew: Bool
    
}


