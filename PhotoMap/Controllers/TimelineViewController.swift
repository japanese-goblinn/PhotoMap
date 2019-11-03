//
//  TimelineViewController.swift
//  PhotoMap
//
//  Created by Kiryl Harbachonak on 10/9/19.
//  Copyright © 2019 Kiryl Harbachonak. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase

class TimelineViewController: UIViewController {
    
    private var categories = Category.allCases
    private var annotations = [PhotoMarkAnnotation]() {
        didSet {
            self.groupData()
            self.tableView.reloadData()
        }
    }
    private var filteredAnnotations = [PhotoMarkAnnotation]()
    private var annotationsGropedByDate: [Date: [PhotoMarkAnnotation]]?
    private var allDates: [Date]?
    private var currentUser: User!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    private var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    private var isFiltering: Bool {
        return searchController.isActive && !isSearchBarEmpty
    }
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let user = Auth.auth().currentUser else { return }
        currentUser = user
        initData()
        setupTableView()
        configureSearchController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    @objc private func showCategories() {
        let categoryVC = CategoriesViewController()
        categoryVC.delegate = self
        categoryVC.categories = categories
        present(categoryVC, animated: true)
    }
    
    private func setupTableView() {
        tableView.register(
            UINib(nibName: "TimelineTableViewCell", bundle: nil),
            forCellReuseIdentifier: "timelineCell"
        )
    }
    
    private func groupData() {
        annotationsGropedByDate = getDataGrouped(
            for: annotations.filter {
                categories.contains($0.category)
            }
        )
        allDates = annotationsGropedByDate?.keys.sorted(by: >)
    }
    
    private func getDataGrouped(for filteredAnnotations: [PhotoMarkAnnotation]) -> [Date: [PhotoMarkAnnotation]] {
        Dictionary(grouping: filteredAnnotations) {
            let dateString = $0.date.toString(with: .monthAndYear)
            let finalDate = dateString.toDate(with: .monthAndYear)!
            return finalDate
        }
    }
    
    private func getAnnotations(for key: Date) -> [PhotoMarkAnnotation]? {
        annotationsGropedByDate?[key]?.sorted {
            $0.date > $1.date
        }
    }
}

extension TimelineViewController: Filterable {
    func filter(by choosedCategories: [Category]) {
        categories = choosedCategories
        groupData()
        tableView.reloadData()
    }
}

extension TimelineViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if isFiltering {
            return 1
        }
        guard let dates = allDates else {
            return 1
        }
        return dates.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if isFiltering {
            return "Search result"
        }
        guard let dates = allDates else {
            return ""
        }
        return dates[section].toString(with: .monthAndYear)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isFiltering {
            return filteredAnnotations.count
        }
        guard let dates = allDates else {
            return 0
        }
        return getAnnotations(for: dates[section])?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard
            let dates = allDates,
            let annotation = getAnnotations(for: dates[indexPath.section])?[indexPath.row]
        else {
            return
        }
        let imageVC = ImageViewController()
        imageVC.hidesBottomBarWhenPushed = true
        imageVC.annoation = annotation
        navigationController?.pushViewController(imageVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        80
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "timelineCell", for: indexPath) as! TimelineTableViewCell
        
        let annotation: PhotoMarkAnnotation
        if isFiltering {
            annotation = filteredAnnotations[indexPath.row]
        } else {
            guard
                let dates = allDates,
                let local = getAnnotations(for: dates[indexPath.section])?[indexPath.row]
            else {
                return cell
            }
            annotation = local
        }
        
        cell.photoImageView.image = annotation.image
        cell.titleLabel.text = annotation.title
        cell.dateLabel.text = "\(annotation.date.toString(with: .standart)) / \(annotation.category.asString.uppercased())"
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none
        return cell
    }
}

extension TimelineViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
      
        let searchBar = searchController.searchBar
        filterContentForSearchText(searchBar.text!)
    }
    
    func filterContentForSearchText(_ searchText: String, category: Category? = nil) {
      
        filteredAnnotations = annotations.filter { (annotation: PhotoMarkAnnotation) -> Bool in
            annotation.title?.lowercased().contains(searchText.lowercased()) ?? false && categories.contains(annotation.category)
        }
        tableView.reloadData()
    }
    
    private func configureSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        definesPresentationContext = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Category", style: .plain, target: self, action: #selector(showCategories)
        )
        navigationItem.searchController = searchController
    }
}

extension TimelineViewController {
    private func initData() {
        let ref = Database.database().reference(withPath: "annotations/\(currentUser.uid)")
        ref.observe(.childAdded) { snapshot in
            DispatchQueue.global().async {
                AnnoationDownloader.getAnnotation(from: snapshot) { [weak self] annotation in
                    DispatchQueue.main.async { [weak self] in
                        let alert = UIAlertController(title: nil, message: "Loading data...", preferredStyle: .alert)

                        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
                        loadingIndicator.hidesWhenStopped = true
                        loadingIndicator.style = UIActivityIndicatorView.Style.gray
                        loadingIndicator.startAnimating();

                        alert.view.addSubview(loadingIndicator)
                        self?.present(alert, animated: true) {
                            self?.dismiss(animated: true)
                        }
                        self?.annotations.append(annotation)
                    }
                }
            }
        }
        ref.observe(.childChanged) { snapshot in
            DispatchQueue.global().async {
                AnnoationDownloader.getAnnotation(from: snapshot) { [weak self] annotation in
                    DispatchQueue.main.async {
                        guard let self = self else { return }
                        let value = self.annotations.first {
                            $0.id == annotation.id
                        }
                        guard let index = self.annotations.firstIndex(of: value!) else {
                            return
                        }
                        self.annotations.remove(at: index)
                        self.annotations.append(annotation)
                    }
                }
            }
        }
    }
}
