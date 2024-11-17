//
//  CryptoViewModelProtocols.swift
//  Crypto
//
//  Created by Rahul Pengoria on 17/11/24.
//

import Combine

protocol Filter {
    func isMatching(coin: CryptoCoinData) -> Bool
}

struct ActiveFilter: Filter {
    func isMatching(coin: CryptoCoinData) -> Bool {
        coin.isActive == true
    }
}

struct InActiveFilter: Filter {
    func isMatching(coin: CryptoCoinData) -> Bool {
        coin.isActive == false
    }
}

struct NewFilter: Filter {
    func isMatching(coin: CryptoCoinData) -> Bool {
        coin.isNew
    }
}

struct TypeFilter: Filter {
    let type: CryptoCoinData.CryptoType
    
    func isMatching(coin: CryptoCoinData) -> Bool {
        coin.type == type
    }
}


protocol CryptoListFetchable {
    /// Fetches the list of cryptocurrencies from the service.
    func fetchCrypoList()
}

protocol CryptoListSearchable {
    /// Searches for cryptocurrencies based on the provided search text.
    func search(with text: String)
}

protocol CryptoListFilterable {
    /// The list of active filters that are applied to the coin list.
    var activeFilters: [CryptoListingViewModel.CryptoFilter] { get }
    /// Clears all active filters and updates the list.
    func clearFilter()
    func applyFilters(_ selectedFilters: Set<CryptoListingViewModel.CryptoFilter>)
}

/// This protocol allows the view model to handle fetching and searching the list of cryptocurrencies as well as managing active filters
typealias CryptoListViewModelInput = CryptoListFetchable & CryptoListSearchable & CryptoListFilterable

/// This protocol allows the view model to provide the filtered list of cryptocurrencies and publish errors when fetching the data fails.
protocol CryptoListViewModelOutput {
    var statePublisher: PassthroughSubject<CryptoListingViewModel.ApiState, Never> { get set }
    var loading: PassthroughSubject<Bool, Never> { get set }
}

/// A typealias that combines both the input and output protocols for the `CryptoListingViewModel`.
typealias CryptoListViewHandler = CryptoListViewModelInput & CryptoListViewModelOutput
