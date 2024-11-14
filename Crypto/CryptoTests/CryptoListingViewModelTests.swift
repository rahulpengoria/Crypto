//
//  CryptoListingViewModelTests.swift
//  CryptoTests
//
//  Created by Rahul Pengoria on 13/11/24.
//

import XCTest
import Combine
@testable import Crypto

final class CryptoCoinFetchableMock: CryptoCoinFetchable {
    var fetchCryptoCoinsResult: Result<[CryptoCoinData], Error>?
    
    func fetchCryptoCoins() async -> Result<[CryptoCoinData], Error> {
        // Return the predefined result if it exists, or provide a default empty result
        return fetchCryptoCoinsResult ?? .success([])
    }
}

// Unit Test Class
class CryptoListingViewModelTests: XCTestCase {
    
    private var viewModel: CryptoListingViewModel!
    private var serviceMock: CryptoCoinFetchableMock!
    private var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        serviceMock = CryptoCoinFetchableMock()
        viewModel = CryptoListingViewModel(service: serviceMock)
        cancellables = []
    }
    
    override func tearDown() {
        cancellables = nil
        viewModel = nil
        serviceMock = nil
        super.tearDown()
    }
    
    func testFetchCryptoList_success() {
        // Arrange
        let expectedCoins = [
            CryptoCoinData(name: "Bitcoin", symbol: "BTC", type: .coin, isActive: true, isNew: false),
            CryptoCoinData(name: "Ethereum", symbol: "ETH", type: .coin, isActive: true, isNew: false)
        ]
        serviceMock.fetchCryptoCoinsResult = .success(expectedCoins)
        
        let expectation = XCTestExpectation(description: "Items publisher should publish coins")
        
        viewModel.statePublisher
            .sink { state in
                if case .loaded(let data) = state {
                    XCTAssertEqual(data, expectedCoins)
                    expectation.fulfill()
                }
                
            }
            .store(in: &cancellables)
        
        // Act
        viewModel.fetchCrypoList()
        
        // Assert
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testFetchCryptoList_failure() {
        // Arrange
        let expectedError = NetworkError.requestFailed
        serviceMock.fetchCryptoCoinsResult = .failure(expectedError)
        
        let expectation = XCTestExpectation(description: "Error publisher should publish error")
        
        viewModel.statePublisher
            .sink { state in
                if case .loadedwithError(let error) = state {
                    XCTAssertEqual(error, expectedError)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // Act
        viewModel.fetchCrypoList()
        
        // Assert
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testSearchFiltersResultsBasedOnText() {
        // Arrange
        viewModel.setCoinsForTesting([
            CryptoCoinData(name: "Bitcoin", symbol: "BTC", type: .coin, isActive: true, isNew: false),
            CryptoCoinData(name: "Ethereum", symbol: "ETH", type: .coin, isActive: true, isNew: false),
            CryptoCoinData(name: "Ripple", symbol: "XRP", type: .coin, isActive: false, isNew: false)
        ])
        
        let expectation = XCTestExpectation(description: "Items publisher should publish filtered results")
        
        viewModel.statePublisher
            .sink { state in
                if case .loaded(let data) = state {
                    XCTAssertEqual(data.count, 1)
                    XCTAssertEqual(data.first?.name, "Ethereum")
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // Act
        viewModel.search(with: "ETH")
        
        // Assert
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testClearFilter_clearsActiveFiltersAndPublishesResults() {
        
        // Arrange
        viewModel.setCoinsForTesting([
            CryptoCoinData(name: "Bitcoin", symbol: "BTC", type: .coin, isActive: true, isNew: false),
            CryptoCoinData(name: "Ethereum", symbol: "ETH", type: .coin, isActive: true, isNew: true),
            CryptoCoinData(name: "Ripple", symbol: "XRP", type: .coin, isActive: false, isNew: false)
        ])
        viewModel.activeFilters = [.active, .new]
        
        // Expect 3 coins total after clearing filters, assuming no filter is applied after clearing
        let expectation = XCTestExpectation(description: "Items publisher should publish unfiltered results")
        
        // Act & Assert
        viewModel.statePublisher
            .sink { state in
                if case .loaded(let data) = state {
                    XCTAssertEqual(data.count, 3) // Expect all 3 coins when filters are cleared
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // Clear filters, which should publish all items
        viewModel.clearFilter()
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(viewModel.activeFilters.isEmpty)
    }
    
    func testToggleActiveFilter_addsAndRemovesActiveFilter() {
        
        // Arrange
        viewModel.setCoinsForTesting([
            CryptoCoinData(name: "Bitcoin", symbol: "BTC", type: .coin, isActive: true, isNew: false),
            CryptoCoinData(name: "Ethereum", symbol: "ETH", type: .coin, isActive: true, isNew: true),
            CryptoCoinData(name: "Ripple", symbol: "XRP", type: .coin, isActive: false, isNew: false)
        ])
        
        let expectation = XCTestExpectation(description: "Items publisher should publish filtered results")
        expectation.expectedFulfillmentCount = 2 // Expect two emissions: one after adding, one after removing
        
        var publishedCounts = [Int]()
        
        // Act
        viewModel.statePublisher
            .sink { state in
                if case .loaded(let data) = state {
                    publishedCounts.append(data.count)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // Toggle `.active` filter on (expect only active coins to be published)
        viewModel.toggleFilter(.active)
        
        // Toggle `.active` filter off (expect all coins to be published again)
        viewModel.toggleFilter(.active)
        
        wait(for: [expectation], timeout: 2.0)
        
        // Assert
        XCTAssertEqual(publishedCounts, [2, 3], "Expected 2 items when filter is on, and 3 items when filter is off")
    }
    
    func testToggleNewFilter_addsAndRemovesNewFilter() {
        
        // Arrange
        viewModel.setCoinsForTesting([
            CryptoCoinData(name: "Bitcoin", symbol: "BTC", type: .coin, isActive: true, isNew: false),
            CryptoCoinData(name: "Ethereum", symbol: "ETH", type: .coin, isActive: true, isNew: true),
            CryptoCoinData(name: "Ripple", symbol: "XRP", type: .coin, isActive: false, isNew: false)
        ])
        
        let expectation = XCTestExpectation(description: "Items publisher should publish filtered results")
        expectation.expectedFulfillmentCount = 2 // Expect two emissions: one after adding, one after removing
        
        var publishedCounts = [Int]()
        
        // Act
        viewModel.statePublisher
            .sink { state in
                if case .loaded(let data) = state {
                    publishedCounts.append(data.count)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // Toggle `.new` filter on (expect only active coins to be published)
        viewModel.toggleFilter(.new)
        
        // Toggle `.new` filter off (expect all coins to be published again)
        viewModel.toggleFilter(.new)
        
        wait(for: [expectation], timeout: 2.0)
        
        // Assert
        XCTAssertEqual(publishedCounts, [1, 3], "Expected 1 items when filter is on, and 3 items when filter is off")
    }
    
    func testToggleCoinFilter_addsAndRemovesCoinFilter() {
        
        // Arrange
        viewModel.setCoinsForTesting([
            CryptoCoinData(name: "Bitcoin", symbol: "BTC", type: .coin, isActive: true, isNew: false),
            CryptoCoinData(name: "Ethereum", symbol: "ETH", type: .coin, isActive: true, isNew: true),
            CryptoCoinData(name: "Ripple", symbol: "XRP", type: .coin, isActive: false, isNew: false)
        ])
        
        let expectation = XCTestExpectation(description: "Items publisher should publish filtered results")
        expectation.expectedFulfillmentCount = 2 // Expect two emissions: one after adding, one after removing
        
        var publishedCounts = [Int]()
        
        // Act
        viewModel.statePublisher
            .sink { state in
                if case .loaded(let data) = state {
                    publishedCounts.append(data.count)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // Toggle `.coin` filter on (expect only active coins to be published)
        viewModel.toggleFilter(.coin)
        
        // Toggle `.coin` filter off (expect all coins to be published again)
        viewModel.toggleFilter(.coin)
        
        wait(for: [expectation], timeout: 2.0)
        
        // Assert
        XCTAssertEqual(publishedCounts, [3, 3], "Expected 3 items when filter is on, and 3 items when filter is off")
    }
    
    func testToggleCoinFilter_withEmptyReult() {
        // Arrange
        viewModel.setCoinsForTesting([
            CryptoCoinData(name: "Bitcoin", symbol: "BTC", type: .token, isActive: true, isNew: false),
            CryptoCoinData(name: "Ethereum", symbol: "ETH", type: .token, isActive: false, isNew: true),
            CryptoCoinData(name: "Ripple", symbol: "XRP", type: .token, isActive: true, isNew: false)
        ])
        
        let expectation = XCTestExpectation(description: "Items publisher should publish filtered results")
        
        // Act: Observe itemsPublisher after toggling the filter
        viewModel.statePublisher
            .sink { state in
                if case .loaded(let data) = state {
                    XCTAssertEqual(data.count, 0)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // Toggle `.coin` filter (expect only active items)
        viewModel.toggleFilter(.coin)
        
        // Assert: Wait for the results
        wait(for: [expectation], timeout: 3.0)
    
    }
    
}

