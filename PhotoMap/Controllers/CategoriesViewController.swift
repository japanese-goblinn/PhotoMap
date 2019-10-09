//
//  CategoriesViewController.swift
//  PhotoMap
//
//  Created by Kiryl Harbachonak on 10/4/19.
//  Copyright © 2019 Kiryl Harbachonak. All rights reserved.
//

import UIKit

class CategoriesViewController: UIViewController {

    @IBOutlet private weak var navigationBar: UINavigationBar!
    @IBOutlet private weak var navigationBarItem: UINavigationItem!
    
    private lazy var tintColor = UIColor(hex: "#5ca1e1")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        
    }
        
    private func setupNavigationBar() {
        navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: tintColor
        ]
        navigationBarItem.title = "Categories"
        navigationBarItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(donePressed(_:))
        )
        navigationBarItem.rightBarButtonItem?.tintColor = tintColor
    }
    
    @objc private func donePressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
}

extension CategoriesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        UITableViewCell()
    }
    
    
}
