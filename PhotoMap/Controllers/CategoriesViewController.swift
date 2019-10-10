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
    @IBOutlet private weak var tableView: UITableView!
    
    private lazy var tintColor = UIColor(hex: "#5ca1e1")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        tableView.register(
            UINib(nibName: "CategoriesTableViewCell", bundle: nil),
            forCellReuseIdentifier: "categoriesCell"
        )
        setupNavigationBar()
        
    }
        
    private func setupNavigationBar() {
        navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: tintColor,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18, weight: .thin)
        ]
        navigationBarItem.title = "Categories"
        navigationBarItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(donePressed(_:))
        )
        navigationBarItem.rightBarButtonItem?.tintColor = tintColor
        navigationBarItem.rightBarButtonItem?.setTitleTextAttributes(
            [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18, weight: .thin)
            ],
            for: .normal
        )
    }
    
    @objc private func donePressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
}

extension CategoriesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Category.allCases.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 62
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoriesCell", for: indexPath) as! CategoriesTableViewCell
        let category = Category.allCases[indexPath.row]
        cell.categoryLabel.text = category.asString.uppercased()
        cell.categoryLabel.textColor = category.color
        cell.categoryCheckbox.color = category.color
        return cell
    }
}
