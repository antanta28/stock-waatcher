//
//  NewsStoryTableViewCell.swift
//  StockApp
//
//  Created by Kirill Fedin on 09.01.2022.
//

import UIKit
import SDWebImage

class NewsStoryTableViewCell: UITableViewCell {
    static let identifier = "NewsStoryTableViewCell"
    static let preferredHeight: CGFloat = 140
    
    struct ViewModel {
        let source: String
        let headline: String
        let dateString: String
        let imageURL: URL?
        
        init(model: NewsStory) {
            self.source = model.source
            self.headline = model.headline
            self.dateString = .string(from: model.datetime)
            self.imageURL = URL(string: model.image)
        }
    }
    
    // MARK: - Views
    private let sourceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .medium)
        return label
    }()
    
    private let headLineLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 20, weight: .regular)
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 14, weight: .light)
        return label
    }()
    
    private let storyImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 6
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .tertiarySystemBackground
        return imageView
    }()
    
    // MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        sourceLabel.text = nil
        headLineLabel.text = nil
        dateLabel.text = nil
        storyImageView.image = nil
    }
    
    private func setupView() {
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        
        addSubview(sourceLabel)
        addSubview(headLineLabel)
        addSubview(dateLabel)
        addSubview(storyImageView)
        
        storyImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            storyImageView.widthAnchor.constraint(equalTo: heightAnchor, constant: -20),
            storyImageView.heightAnchor.constraint(equalTo: heightAnchor, constant: -20),
            storyImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            storyImageView.rightAnchor.constraint(equalTo: rightAnchor, constant: -10)
        ])
        
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dateLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 10),
            dateLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),
            dateLabel.rightAnchor.constraint(equalTo: storyImageView.leftAnchor, constant: -10),
            dateLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        sourceLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sourceLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 10),
            sourceLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            sourceLabel.rightAnchor.constraint(equalTo: storyImageView.leftAnchor, constant: -10),
            sourceLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        headLineLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            headLineLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 10),
            headLineLabel.topAnchor.constraint(equalTo: sourceLabel.bottomAnchor, constant: 5),
            headLineLabel.rightAnchor.constraint(equalTo: storyImageView.leftAnchor, constant: -10),
            headLineLabel.bottomAnchor.constraint(equalTo: dateLabel.topAnchor, constant: -5)
        ])
    }
    
    public func configure(with viewModel: ViewModel) {
        headLineLabel.text = viewModel.headline
        sourceLabel.text = viewModel.source
        dateLabel.text = viewModel.dateString
        
        storyImageView.sd_setImage(with: viewModel.imageURL, completed: nil)
    }
}
