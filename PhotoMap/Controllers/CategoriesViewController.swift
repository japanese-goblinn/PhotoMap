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
    lazy var categories = [Category]()
    weak var delegate: Filterable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupNavigationBar()
    }
    
    private func setupTableView() {
        tableView.tableFooterView = UIView()
        tableView.register(
            UINib(nibName: "CategoriesTableViewCell", bundle: nil),
            forCellReuseIdentifier: "categoriesCell"
        )
    }
        
    private func setupNavigationBar() {
        
        navigationBar.titleTextAttributes = [
            .foregroundColor: tintColor,
            .font: UIFont.systemFont(ofSize: 18, weight: .thin)
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
                .font: UIFont.systemFont(ofSize: 18, weight: .thin)
            ],
            for: .normal
        )
    }
    
    @objc private func donePressed(_ sender: UIBarButtonItem) {
        delegate?.filter(by: categories)
        dismiss(animated: true)
    }
    
    private func addTapGesterRecognizer(for cell: CategoriesTableViewCell) {
        let checkBoxTouchGester = UITapGestureRecognizer(
            target: self,
            action: #selector(checkBoxPressed(_:))
        )
        let cellTouchGester = UITapGestureRecognizer(
            target: self,
            action: #selector(cellPressed(_:)))
        cell.categoryCheckbox.addGestureRecognizer(checkBoxTouchGester)
        cell.addGestureRecognizer(cellTouchGester)
    }
    
    @objc private func cellPressed(_ sender: UITapGestureRecognizer) {
        guard let cell = sender.view as? CategoriesTableViewCell else {
            return
        }
        changeState(for: cell.categoryCheckbox)
    }
    
    @objc private func checkBoxPressed(_ sender: UITapGestureRecognizer) {
        guard let checkbox = sender.view as? CheckboxView else {
            return
        }
        changeState(for: checkbox)
    }
    
    private func changeState(for checkbox: CheckboxView) {
        checkbox.isChecked.toggle()
        if !categories.contains(checkbox.category) {
            categories.append(checkbox.category)
        } else {
            let index = categories.firstIndex(of: checkbox.category)!
            categories.remove(at: index)
        }
    }
}

extension CategoriesViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Category.allCases.count
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "categoriesCell",
            for: indexPath
        ) as! CategoriesTableViewCell
        
        addTapGesterRecognizer(for: cell)
        let category = Category.allCases[indexPath.row]
        cell.categoryLabel.text = category.asString.uppercased()
        cell.categoryLabel.textColor = category.color
        cell.categoryCheckbox.category = category
        cell.categoryCheckbox.isChecked = categories.contains(category)
        return cell
    }
}
