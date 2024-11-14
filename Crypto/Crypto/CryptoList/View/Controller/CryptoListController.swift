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
    
    /// A filter button that opens filter options for cryptocurrency data.
    private lazy var filterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "tray.circle.fill"), for: .normal)
        button.tintColor = UIColor.secondaryTextColor
        button.backgroundColor = UIColor.primaryBackgroundColor
        button.layer.cornerRadius = 30
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.borderColor.cgColor
        button.imageView?.contentMode = .scaleAspectFit
        button.isHidden = true
        return button
    }()
    
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
    
    // MARK: - Setup Methods
    
    /// Configures the view by setting up navigation, table view, and filter button.
    private func setupView() {
        setupNavigation()
        setupTableView()
        setupFilterButton()
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
                        self?.updateFilterButton()
                    case .loadedwithError(let error):
                        self?.loader(show: false)
                        self?.showErrorAlert(with: error)
                }
                
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
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        tableView.dataSource = self
    }
}

// MARK: - Filter Button Setup
extension CryptoListController {
    
    private func setupFilterButton() {
        filterButton.addTarget(self, action: #selector(showFilterOptions), for: .touchUpInside)
        view.addSubview(filterButton)
        filterButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            filterButton.widthAnchor.constraint(equalToConstant: 60),
            filterButton.heightAnchor.constraint(equalToConstant: 60),
            filterButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    /// Updates the filter button's visibility based on certain conditions.
    private func updateFilterButton() {
        filterButton.isHidden = false
    }
    
    /// Presents filter options in an action sheet, allowing users to toggle filters.
    @objc private func showFilterOptions() {
        let alert = UIAlertController(title: "Filter Options", message: "Select filters", preferredStyle: .actionSheet)
        
        for filter in CryptoListingViewModel.CryptoFilter.allCases {
            let activeFilterAction = UIAlertAction(
                title: filter.filterText + (viewModel.activeFilters.contains(filter) ? " ✓" : ""),
                style: .default
            ) { _ in
                self.viewModel.toggleFilter(filter)
            }
            alert.addAction(activeFilterAction)
        }
        
        alert.addAction(UIAlertAction(title: "Clear Filters", style: .destructive) { _ in
            self.viewModel.clearFilter()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
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


