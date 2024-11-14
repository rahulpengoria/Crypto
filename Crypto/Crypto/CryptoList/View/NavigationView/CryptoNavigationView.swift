import UIKit

class NavigationTitleView: UIView {
    
    private lazy var titleLabel: UILabel = {
        let titleLabel: UILabel = UILabel()
        titleLabel.text = "CryptoCoin"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        titleLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return titleLabel
    }()
    
    private lazy var searchBar: UISearchBar = {
        let searchBar: UISearchBar = UISearchBar()
        searchBar.placeholder = "Search..."
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView: UIStackView = UIStackView(arrangedSubviews: [titleLabel, searchBar])
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private var searchBarWidthConstraint: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            heightAnchor.constraint(equalToConstant: 44)
        ])
        searchBarWidthConstraint = searchBar.widthAnchor.constraint(equalToConstant: 0)
        searchBarWidthConstraint.isActive = true
    }
    
    // Method to show the search bar with a proportional width
    func showSearchBar() {
        searchBarWidthConstraint.isActive = false
        searchBarWidthConstraint = searchBar.widthAnchor.constraint(equalTo: widthAnchor,
                                                                    multiplier: 0.7)
        searchBarWidthConstraint.isActive = true
        
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
        searchBar.becomeFirstResponder()
    }
    
    // Method to hide the search bar and reset to zero width
    func hideSearchBar() {
        searchBarWidthConstraint.isActive = false
        searchBarWidthConstraint = searchBar.widthAnchor.constraint(equalToConstant: 0)
        searchBarWidthConstraint.isActive = true
        
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
        searchBar.resignFirstResponder()
    }
    
    func setSearchDelegate(_ delegate: UISearchBarDelegate) {
        searchBar.delegate = delegate
    }
}

