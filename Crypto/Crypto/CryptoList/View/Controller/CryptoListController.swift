//
//  CryptoListController.swift
//  Crypto
//
//  Created by Rahul Pengoria on 13/11/24.
//

import UIKit
import Combine

/// A view controller that displays a list of cryptocurrencies.
final class CryptoListController: UIViewController {
    
    // MARK: - Properties
    
    /// The view model responsible for providing data and handling business logic.
    private let viewModel: CryptoListViewModel
    
    /// A set to store Combine's cancellable instances, for managing the lifecycle of subscriptions.
    private var cancellables: Set<AnyCancellable> = []
    
    /// The table view displaying the list of cryptocurrencies.
    private let tableView: UITableView = UITableView()
    
    /// The custom navigation view with a search bar.
    private lazy var navigationView = NavigationTitleView()
    
    private lazy var filterFooterView: FilterFooterView = FilterFooterView(frame: .zero)
    
    /// The array of cryptocurrency data items to display, which triggers a reload when updated.
    private var items: [CryptoCoinData] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Initializers
    init(viewModel: CryptoListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCell()
        setupView()
        bind()
        viewModel.fetchCrypoList()
    }
    
    private func addFooterView() {
        view.addSubview(filterFooterView)
        filterFooterView.translatesAutoresizingMaskIntoConstraints = false
        let footerViewTopAnchor = filterFooterView.topAnchor.constraint(equalTo: tableView.bottomAnchor,
                                                                        constant: 0)
        
        let footerViewBottomAnchor = filterFooterView.bottomAnchor.constraint(equalTo: view.bottomAnchor,
                                                                              constant: 0)
        let footerViewLeftAnchor = filterFooterView.leftAnchor.constraint(equalTo: view.leftAnchor,
                                                                          constant: 0)
        let footerViewRightAnchor = filterFooterView.rightAnchor.constraint(equalTo: view.rightAnchor,
                                                                            constant: 0)
        let footerViewHeight = filterFooterView.heightAnchor.constraint(equalToConstant: 100)
        
        NSLayoutConstraint.activate([footerViewTopAnchor,
                                     footerViewBottomAnchor,
                                     footerViewLeftAnchor,
                                     footerViewRightAnchor,
                                     footerViewHeight])
    }
    
    // MARK: - Setup Methods
    
    /// Configures the view by setting up navigation, table view, and filter button.
    private func setupView() {
        setupNavigation()
        setupTableView()
        addFooterView()
    }
    
    /// Registers the custom table view cell used to display cryptocurrency data.
    private func registerCell() {
        tableView.register(CryptoTableViewCell.self, forCellReuseIdentifier: "CryptoCell")
    }
    
    // MARK: - Bind Method
    
    /// This method subscribes to the `itemsPublisher` and `errorPublisher` from the view model and updates the UI based on the emitted values.
    private func bind() {
        viewModel.statePublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                switch state {
                    case .loading:
                        self?.loader(show: true)
                    case .loaded(let data):
                        self?.loader(show: false)
                        self?.items = data
                    case .loadedwithError(let error):
                        self?.loader(show: false)
                        self?.showErrorAlert(with: error)
                }
                
            }
            .store(in: &cancellables)
        
        filterFooterView.filterUpdates
            .sink { [weak self] selectedFilters in
                self?.viewModel.applyFilters(selectedFilters)
            }
            .store(in: &cancellables)

    }
    
    private func loader(show: Bool) {
        if show {
            self.view.showLoader()
        } else {
            self.view.hideLoader()
        }
    }
}

// MARK: - Navigation Setup
extension CryptoListController {
    
    private func setupNavigation() {
        setupNavigationBarAppearance()
        navigationItem.titleView = navigationView
        navigationView.setSearchDelegate(self)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search,
                                                            target: self,
                                                            action: #selector(didTapSearchButton))
    }
    
    private func setupNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = UIColor.navigationBarBackground
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.tintColor = UIColor.navigationBarText
    }
    
    @objc func didTapSearchButton() {
        navigationView.showSearchBar()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                            target: self,
                                                            action: #selector(didTapCancelButton))
    }
    
    @objc func didTapCancelButton() {
        navigationView.hideSearchBar()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search,
                                                            target: self,
                                                            action: #selector(didTapSearchButton))
    }
}

// MARK: - TableView Setup
extension CryptoListController {
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        tableView.dataSource = self
    }
}

// MARK: - UITableViewDataSource
extension CryptoListController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CryptoCell", for: indexPath) as! CryptoTableViewCell
        cell.configure(with: items[indexPath.row])
        return cell
    }
}

// MARK: - UISearchBarDelegate
extension CryptoListController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.search(with: searchText)
    }
}

// MARK: - Alert Presentation
extension CryptoListController {
    
    /// Displays an alert to inform the user of an error.
    /// - Parameter error: The error to display.
    private func showErrorAlert(with error: Error) {
        let alertController = UIAlertController(title: error.localizedDescription,
                                                message: nil,
                                                preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: {_ in 
            if case .emptyDataWithFilteredApplied = error as? NetworkError {
                self.viewModel.clearFilter()
            }
        })
        alertController.addAction(defaultAction)
        
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
}
