//
//  NewsHeaderView.swift
//  StockApp
//
//  Created by Kirill Fedin on 09.01.2022.
//

import UIKit


protocol NewsHeaderViewDelegate: AnyObject {
    func newsHeaderViewDidTapAddButton(_ headerView: NewsHeaderView)
}

class NewsHeaderView: UITableViewHeaderFooterView {
    static let identifier = "NewsHeaderView"
    static let preferredHeight: CGFloat = 50
    
    weak var delegate: NewsHeaderViewDelegate?
    
    struct ViewModel {
        let title: String
        let shouldShowAddButton: Bool
    }
    
    private let label: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 28)
        return label
    }()
    
    private let button: UIButton = {
        let button = UIButton()
        button.setTitle("+ Watchlist", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        return button
    }()
    
    // MARK: - Init
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        label.text = nil
    }
    
    // MARK: - Private
    private func setupView() {
        contentView.backgroundColor = .secondarySystemBackground
        
        contentView.addSubview(label)
        contentView.addSubview(button)
        
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leftAnchor.constraint(equalTo: leftAnchor, constant: 10),
            label.topAnchor.constraint(equalTo: topAnchor),
            label.rightAnchor.constraint(equalTo: rightAnchor, constant: -10),
            label.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.rightAnchor.constraint(equalTo: rightAnchor, constant: -button.frame.width - 10),
            button.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.5),
            button.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    // MARK: - Public
    public func configure(with viewModel: ViewModel) {
        label.text = viewModel.title
        button.isHidden = !viewModel.shouldShowAddButton
    }
    
    public func hideButton(_ value: Bool = true) {
        button.isHidden = value
    }
    
    // MARK: - Private
    @objc private func didTapButton() {
        delegate?.newsHeaderViewDidTapAddButton(self)
    }
}
