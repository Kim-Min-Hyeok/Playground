//
//  ViewController.swift
//  reusable_project
//
//  Created by Minhyeok Kim on 2024/05/23.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.background
        
        setUI()
    }

    let fontTestLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.primary
        label.text = "폰트 테스트"
        label.font = UIFont.header1()
        return label
    }()
    
    func setUI() {
        view.addSubview(fontTestLabel)
        
        NSLayoutConstraint.activate([
            fontTestLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            fontTestLabel.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
    }
}

