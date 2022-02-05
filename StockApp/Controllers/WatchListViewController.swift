//
//  ViewController.swift
//  StockApp
//
//  Created by Kirill Fedin on 08.01.2022.
//

import UIKit
import FloatingPanel
class WatchListViewController: UIViewController {
    private var searchTimer: Timer?

    // Model
    private var watchListMap: [String: [CandleStick]] = [:]
    
    // ViewModel
    private var viewModels: [WatchListTableViewCell.ViewModel] = []
    private var observer: NSObjectProtocol?
    // MARK: - Views
    private let titleView = TitleView()
    private var panel: FloatingPanelController?
    
    private let tableView = UITableView()
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setConstraints()
        
        setupSearchController()
        setupTitleView()
        
        setupTableView()
        setupFloatingPanel()
        
        fetchWatchListData()
        
        setupObserver()
    }
    
    private func setupView() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(tableView)
    }
    
    // MARK: - Private
    private func setupObserver() {
        observer = NotificationCenter.default.addObserver(forName: .didAddToWatchList, object: nil, queue: .main) { [weak self] _ in
            self?.viewModels.removeAll()
            self?.fetchWatchListData()
        }
    }
    
    private func setupSearchController() {
        let resultVC = SearchResultsViewController()
        resultVC.delegate = self
        let searchVC = UISearchController(searchResultsController: resultVC)
        searchVC.searchResultsUpdater = self
        
        navigationItem.searchController = searchVC
    }
    
    private func setupTitleView() {
        NSLayoutConstraint.activate([
            titleView.widthAnchor.constraint(equalToConstant: view.frame.width),
            titleView.heightAnchor.constraint(
                equalToConstant: navigationController?.navigationBar.frame.height ?? 100
            )
        ])
        
        navigationItem.titleView = titleView
    }
    
    private func setupFloatingPanel() {
        let viewController = NewsViewController(type: .topStories)
        
        panel = FloatingPanelController()
        panel?.surfaceView.backgroundColor = .secondarySystemBackground
        panel?.set(contentViewController: viewController)
        panel?.addPanel(toParent: self)
        panel?.track(scrollView: viewController.tableView)
        
        panel?.delegate = self
    }
    
    private func setupTableView() {
        tableView.register(
            WatchListTableViewCell.self,
            forCellReuseIdentifier: WatchListTableViewCell.identifier
        )
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func fetchWatchListData() {
        let symbols = PersistenceManager.shared.watchList
        
        createPlaceholderViewModels()
        
        let group = DispatchGroup()
        
        for symbol in symbols where watchListMap[symbol] == nil {
            group.enter()
            
            APICaller.shared.marketData(for: symbol, numberOfDays: 7) { [weak self] result in
                defer {
                    group.leave()
                }
                
                switch result {
                case .success(let data):
                    let candleSticks = data.candleSticks
                    self?.watchListMap[symbol] = candleSticks
                case .failure(let error):
                    print(error)
                }
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.createViewModels()
            self?.tableView.reloadData()
        }
        tableView.reloadData()
    }
    
    private func createPlaceholderViewModels() {
        let symbols = PersistenceManager.shared.watchList
        
        for symbol in symbols {
            viewModels.append(
                .init(
                    symbol: symbol,
                    companyName: UserDefaults.standard.string(forKey: symbol) ?? "Unknown",
                    price: "0.00",
                    changeColor: .label,
                    changePercentage: "0.00",
                    chartViewModel: .init(
                        data: [],
                        showLegend: false,
                        showAxis: false,
                        fillColor: .clear
                    )
                )
            )
        }
        
        self.viewModels = viewModels.sorted(by: { $0.symbol < $1.symbol })
        tableView.reloadData()
    }
    
    private func createViewModels() {
        var viewModels = [WatchListTableViewCell.ViewModel]()
        
        for (symbol, candleSticks) in watchListMap {
            let changePercentage = candleSticks.getPercentage()
            
            viewModels.append(
                .init(
                    symbol: symbol,
                    companyName: UserDefaults.standard.string(forKey: symbol) ?? "Company..",
                    price: getLatestClosingPrice(from: candleSticks),
                    changeColor: changePercentage < 0 ? .systemRed : .systemGreen,
                    changePercentage: .percentage(from: changePercentage),
                    chartViewModel: .init(
                        data: candleSticks.reversed().map { $0.close },
                        showLegend: false,
                        showAxis: false,
                        fillColor: changePercentage < 0 ? .systemRed : .systemGreen
                    )
                )
            )
        }
        
        self.viewModels = viewModels.sorted(by: { $0.symbol < $1.symbol } )
    }
    
    private func getLatestClosingPrice(from data: [CandleStick]) -> String {
        guard let closingPrice = data.first?.close else {
            return ""
        }
        
        return .formatted(number: closingPrice)
    }
}

// MARK: - UISearchResultsUpdating
extension WatchListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text,
              !query.trimmingCharacters(in: .whitespaces).isEmpty,
              let resultVC = searchController
                .searchResultsController as? SearchResultsViewController
        else {
            return
        }
        searchTimer?.invalidate()
        
        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false, block: { _ in
            
            APICaller.shared.search(query: query) { result in
                switch result {
                case .success(let response):
                    DispatchQueue.main.async {
                        resultVC.update(with: response.result)
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        resultVC.update(with: [])
                    }
                    print(error)
                }
            }
        })
    }
}

// MARK: - SearchResultsViewControllerDelegate
extension WatchListViewController: SearchResultsViewControllerDelegate {
    func searchResultsViewControllerDidSelect(searchResult: SearchResult) {
        navigationItem.searchController?.searchBar.resignFirstResponder()
        
        HapticsManager.shared.vibrateForSelection()
        
        let viewController = StockDetailViewController(
            symbol: searchResult.displaySymbol,
            companyName: searchResult.description
        )
        let navViewController = UINavigationController(rootViewController: viewController)
        viewController.title = searchResult.description
        
        present(navViewController, animated: true)
    }
}

// MARK: - FloatingPanelControllerDelegate
extension WatchListViewController: FloatingPanelControllerDelegate {
    func floatingPanelDidChangeState(_ fpc: FloatingPanelController) {
        navigationItem.titleView?.isHidden = fpc.state == .full
    }
}

extension WatchListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            
            PersistenceManager.shared.removeFromWatchList(symbol: viewModels[indexPath.row].symbol)
            viewModels.remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            tableView.endUpdates()
        }
    }
}

extension WatchListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: WatchListTableViewCell.identifier,
            for: indexPath
        ) as? WatchListTableViewCell else {
            return UITableViewCell()
        }
        
        cell.configure(with: viewModels[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return WatchListTableViewCell.preferredHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        HapticsManager.shared.vibrateForSelection()
        
        let viewModel = viewModels[indexPath.row]
        let viewController = StockDetailViewController(
            symbol: viewModel.symbol,
            companyName: viewModel.companyName,
            candleStickData: watchListMap[viewModel.symbol] ?? []
        )
        let navVC = UINavigationController(rootViewController: viewController)
        
        present(navVC, animated: true)
    }
}
