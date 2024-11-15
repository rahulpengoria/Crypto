//
//  CryptoListViewModel.swift
//  Crypto
//
//  Created by Rahul Pengoria on 13/11/24.
//

import Combine

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
typealias CryptoListViewModel = CryptoListViewModelInput & CryptoListViewModelOutput

/// This class is used as viewmodel for crypto list controller which is reponsible for managing list
final class CryptoListingViewModel: CryptoListViewModel {
    
    enum ApiState {
        case loading
        case loaded(data: [CryptoCoinData])
        case loadedwithError(error: NetworkError)
    }
    
    
    /// Defines the possible filters that can be applied to the cryptocurrency list.
    enum CryptoFilter: Equatable, CaseIterable {
        case active
        case new
        case coin
        case inActive
        case token
        
        static func ==(lhs: CryptoFilter, rhs: CryptoFilter) -> Bool {
            switch (lhs, rhs) {
                case (.active, .active),
                    (.new, .new),
                    (.coin, .coin),
                    (.inActive, .inActive),
                    (.token, .token) :
                    return true
                default:
                    return false
            }
        }
        
        var filterText: String {
            switch self {
                case .active:
                    return "Active Coins"
                case .new:
                    return "New Coins"
                case .coin:
                    return "Only Coin"
                case .inActive:
                    return "InActive Coins"
                case .token:
                    return "Only Token"
            }
        }
    }
    /// A publisher that emits the filtered list of cryptocurrencies.
    var statePublisher = PassthroughSubject<ApiState, Never>()
    
    /// A publisher that start loader whrn api start calling
    var loading = PassthroughSubject<Bool, Never>()
    
    /// A list of all cryptocurrencies retrieved from the service.
    private var coins: [CryptoCoinData] = []
    
    /// The list of active filters currently applied to the coin list.
    var activeFilters: [CryptoFilter] = []
    
    /// The search text used to filter the cryptocurrency list.
    private var searchText: String =  "" {
        didSet {
            filterCoins()
        }
    }
    
    internal func setCoinsForTesting(_ coins: [CryptoCoinData]) {
        self.coins = coins
    }
    
    /// A service responsible for fetching cryptocurrency data.
    private let service: CryptoCoinFetchable
    
    init(service: CryptoCoinFetchable) {
        self.service = service
    }
    
    /// Filters the list of cryptocurrencies based on active filters and the search text.
    private func filterCoins() {
        // Combine all conditions into a single predicate function
        let filteredCoins = coins.filter { coin in
            let isMatch = activeFilters.allSatisfy { filter in
                switch filter {
                    case .active:
                        return coin.isActive
                    case .new:
                        return coin.isNew
                    case .coin:
                        return coin.type == .coin
                    case .token:
                        return coin.type == .token
                    case .inActive:
                        return !coin.isActive
                }
            }
            
            // Check if the coin matches the search text
            let searchMatch = searchText.isEmpty || coin.name.contains(searchText) || coin.symbol.contains(searchText)
            
            return isMatch && searchMatch
        }
        statePublisher.send(.loaded(data: filteredCoins))
    }

    
}
//MARK: CryptoListFetchable
extension CryptoListingViewModel {
    
    /// Fetches the list of cryptocurrencies from the service and updates the publishers.
    func fetchCrypoList() {
        Task {
            statePublisher.send(.loading)
            let result = await service.fetchCryptoCoins()
            switch result {
                case .success(let cryptos):
                    coins = cryptos
                    statePublisher.send(.loaded(data: cryptos))
                case .failure(let error):
                    statePublisher.send(.loadedwithError(error: error as! NetworkError))
            }
        }
        
    }
    
}

//MARK: CryptoListSearchable
extension CryptoListingViewModel {
    /// Updates the search text and triggers filtering of the coin list.
    func search(with text: String) {
        searchText = text
    }
}

//MARK: CryptoListFilterable
extension CryptoListingViewModel {
    /// Clears all active filters and triggers a re-filtering of the coin list.
    func clearFilter() {
        self.activeFilters.removeAll()
        self.filterCoins()
    }
    
    func applyFilters(_ selectedFilters: Set<CryptoListingViewModel.CryptoFilter>) {
        activeFilters = Array(selectedFilters)
        filterCoins()
    }
}

