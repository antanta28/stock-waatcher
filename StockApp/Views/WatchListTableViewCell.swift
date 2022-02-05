//
//  WatchListTableViewCell.swift
//  StockApp
//
//  Created by Kirill Fedin on 13.01.2022.
//

import UIKit

class WatchListTableViewCell: UITableViewCell {
    static let identifier = "WatchListTableViewCell"
    static let preferredHeight: CGFloat = 60
    
    struct ViewModel {
        let symbol: String
        let companyName: String
        let price: String
        let changeColor: UIColor // red or green
        let changePercentage: String
        let chartViewModel: StockChartView.ViewModel
    }
    
    private let symbolLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        return label
    }()
    
    private let companyNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private let changeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.textColor = .white
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.layer.cornerRadius = 6
        label.clipsToBounds = true
        return label
    }()
    
    private let miniChartView: StockChartView = {
        let chartView = StockChartView()
        chartView.isUserInteractionEnabled = false
        return chartView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupView()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        symbolLabel.text = nil
        companyNameLabel.text = nil
        priceLabel.text = nil
        changeLabel.text = nil
        
        miniChartView.reset()
    }
    
    private func setupView() {
        addSubview(symbolLabel)
        addSubview(companyNameLabel)
        addSubview(miniChartView)
        addSubview(priceLabel)
        addSubview(changeLabel)
    }
    
    private func setConstraints() {
        symbolLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            symbolLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 10),
            symbolLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -10)
        ])
        
        companyNameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            companyNameLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 10),
            companyNameLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 10)
        ])

        let priceWidth: CGFloat = 60
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            priceLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -10),
            priceLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -10),
            priceLabel.widthAnchor.constraint(equalToConstant: priceWidth)
        ])
        
        changeLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            changeLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -10),
            changeLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 10),
            changeLabel.widthAnchor.constraint(equalToConstant: priceWidth)
        ])
        
        miniChartView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            miniChartView.rightAnchor.constraint(equalTo: priceLabel.leftAnchor, constant: -10),
            miniChartView.centerYAnchor.constraint(equalTo: centerYAnchor),
            miniChartView.heightAnchor.constraint(equalTo: heightAnchor, constant: -10),
            miniChartView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.35)
        ])
    }
    
    public func configure(with viewModel: ViewModel) {
        symbolLabel.text = viewModel.symbol
        companyNameLabel.text = viewModel.companyName
        priceLabel.text = viewModel.price
        changeLabel.text = viewModel.changePercentage
        changeLabel.backgroundColor = viewModel.changeColor
        
        miniChartView.configure(with: viewModel.chartViewModel)
//        miniChartView.configure(with: <#T##StockChartView.ViewModel#>)
    }
}
