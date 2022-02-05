//
//  PanelViewController.swift
//  StockApp
//
//  Created by Kirill Fedin on 09.01.2022.
//

import UIKit

class PanelViewController: UIViewController {

    private let grabberView: UIView = {
        let view = UIView()
        view.backgroundColor = .label
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setConstraints()
    }
    
    private func setupView() {
        view.backgroundColor = .secondarySystemBackground
        
        view.addSubview(grabberView)
    }
    
    private func setConstraints() {
        grabberView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            grabberView.widthAnchor.constraint(equalToConstant: 100),
            grabberView.heightAnchor.constraint(equalToConstant: 4),
            grabberView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            grabberView.topAnchor.constraint(equalTo: view.topAnchor, constant: 10)
        ])
    }
}
