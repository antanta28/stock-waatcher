//
//  StockDetailViewController.swift
//  StockApp
//
//  Created by Kirill Fedin on 08.01.2022.
//

import UIKit
import SafariServices

class StockDetailViewController: UIViewController {
    
    // MARK: - Properties
    private let symbol: String
    private let companyName: String
    private var candleStickData: [CandleStick]
    
    private var stories: [NewsStory] = []
    private var metrics: Metrics?
    
    // MARK: - View
    private let tableView = UITableView()
    
    // MARK: - Init
    init(
        symbol: String,
        companyName: String,
        candleStickData: [CandleStick] = []
    ) {
        self.symbol = symbol
        self.companyName = companyName
        self.candleStickData = candleStickData
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupTableView()
        
        setConstraints()
        
        fetchFinancialData()
        fetchNews()
    }
    
    // MARK: - Private
    private func setupView() {
        view.backgroundColor = .systemBackground
        title = companyName
        setupCloseButton()
        
        view.addSubview(tableView)
    }
    
    private func setupTableView() {
        tableView.register(
            NewsHeaderView.self,
            forHeaderFooterViewReuseIdentifier: NewsHeaderView.identifier
        )
        tableView.register(
            NewsStoryTableViewCell.self,
            forCellReuseIdentifier: NewsStoryTableViewCell.identifier
        )
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.tableHeaderView = UIView(
            frame: .init(
                x: 0,
                y: 0,
                width: view.frame.width,
                height: (view.frame.width * 0.7) + 100
            )
        )
    }
    
    private func setupCloseButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(didTapClose)
        )
    }
    
    @objc private func didTapClose() {
        dismiss(animated: true)
    }
    
    private func fetchFinancialData() {
        let group = DispatchGroup()
        
        if (candleStickData.isEmpty) {
            group.enter()
            APICaller.shared.marketData(for: symbol) { [weak self] result in
                defer {
                    group.leave()
                }
                
                switch result {
                case .success(let response):
                    self?.candleStickData = response.candleSticks
                case .failure(let error):
                    print(error)
                }
            }
        }
        
        group.enter()
        APICaller.shared.financialMetrics(for: symbol) { [weak self] result in
            defer {
                group.leave()
            }
            
            switch result {
                
            case .success(let response):
                let metrics = response.metric
                self?.metrics = metrics
            case .failure(let error):
                print(error)
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.renderChart()
        }
        
    }
    
    private func fetchNews() {
        APICaller.shared.news(for: .company(symbol: symbol)) { [weak self] result in
            switch  result {
            case .success(let stories):
                DispatchQueue.main.async {
                    self?.stories = stories
                    self?.tableView.reloadData()
                }
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func renderChart() {
        let headerView = StockDetailHeader(
            frame: CGRect(
                x: 0,
                y: 0,
                width: view.frame.width,
                height: (view.frame.width * 0.7) + 100
            )
        )
        
        var viewModels = [MetricCollectionViewCell.ViewModel]()
        if let metrics = metrics {
            viewModels.append(.init(name: "52W High", value: "\(metrics.annualWeekHigh)"))
            viewModels.append(.init(name: "52W Low", value: "\(metrics.annualWeekLow)"))
            viewModels.append(.init(name: "52W Return", value: "\(metrics.annualWeekPriceReturnDaily)"))
            viewModels.append(.init(name: "Beta", value: "\(metrics.beta)"))
            viewModels.append(.init(name: "10D Volume", value: "\(metrics.tenDayAverageTradingVolume)"))
        }
        
        let change = candleStickData.getPercentage()
        headerView.configure(
            chartViewModel: .init(
                data: candleStickData.reversed().map { $0.close },
                showLegend: true,
                showAxis: true,
                fillColor: change < 0 ? .systemRed : .systemGreen
            ),
            metricViewModels: viewModels)
        tableView.tableHeaderView = headerView
    }
    
    private func setConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

// MARK: - UITableViewDelegate
extension StockDetailViewController: UITableViewDelegate {
    
}

// MARK: - UITableViewDataSource
extension StockDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: NewsStoryTableViewCell.identifier,
            for: indexPath
        ) as? NewsStoryTableViewCell else {
            return UITableViewCell()
        }
        
        cell.configure(with: .init(model: stories[indexPath.row]))
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return NewsStoryTableViewCell.preferredHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: NewsHeaderView.identifier
        ) as? NewsHeaderView else {
            return nil
        }
        header.delegate = self
        header.configure(
            with: .init(
                title: symbol.uppercased(),
                shouldShowAddButton: !PersistenceManager.shared.watchListContains(symbol: symbol)
            )
        )
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return NewsHeaderView.preferredHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        HapticsManager.shared.vibrateForSelection()
        
        guard let url = URL(string: stories[indexPath.row].url) else { return }
        let viewController = SFSafariViewController(url: url)
        present(viewController, animated: true)
    }
}

// MARK: - NewsHeaderViewDelegate
extension StockDetailViewController: NewsHeaderViewDelegate {
    func newsHeaderViewDidTapAddButton(_ headerView: NewsHeaderView) {
        HapticsManager.shared.vibrate(for: .success)
        
        headerView.hideButton()
        PersistenceManager.shared.addToWatchList(
            symbol: symbol,
            companyName: companyName
        )
        
        let alert = UIAlertController(
            title: "Added to Watchlist",
            message: "We're added \(companyName) to watchlist",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(
            title: "Cancel",
            style: .cancel
        ))
        present(alert, animated: true)
    }
}
