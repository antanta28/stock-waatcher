//
//  TitleView.swift
//  StockApp
//
//  Created by Kirill Fedin on 08.01.2022.
//

import UIKit

class TitleView: UIView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Stocks"
        label.font = .systemFont(ofSize: 35, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    init() {
        super.init(frame: .zero)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 10),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -10)
        ])
    }
}
