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
    
    @IBOutlet weak var tableView: UITableView!
    
    private var categories = Category.allCases
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    private var filteredAnnotations = [PhotoMarkAnnotation]()
    private var annotationsGropedByDate: [Date: [PhotoMarkAnnotation]]?
    private var allDates: [Date]?
    
    private var currentUser: User!
    
    private let downloadGroup = DispatchGroup()
    private let refreshControl = UIRefreshControl()
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    private var isFiltering: Bool {
        return searchController.isActive && !isSearchBarEmpty
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let user = Auth.auth().currentUser else { return }
        currentUser = user
        setupTableView()
        setupRefreshControl()
        configureSearchController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getData()
        setUpNavigationBar()
        if refreshControl.isRefreshing {
            refreshControl.endRefreshing()
            refreshControl.beginRefreshing()
        }
    }
    
    private func setUpNavigationBar() {
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.tintColor = .systemBlue
    }
    
    private func setupRefreshControl() {
        refreshControl.attributedTitle = NSAttributedString(string: "Update images")
        refreshControl.addTarget(
            self, action: #selector(refresh(_:)), for: UIControl.Event.valueChanged
        )
        tableView.insertSubview(refreshControl, at: 0)
    }
    
    @objc private func refresh(_ sender: AnyObject) {
        tableView.reloadData()
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
            for: appDelegate.annotations.filter {
                categories.contains($0.category)
            }
        )
        allDates = annotationsGropedByDate?.keys.sorted(by: >)
    }
    
    private func getDataGrouped(for filteredAnnotations: [PhotoMarkAnnotation]) -> [Date: [PhotoMarkAnnotation]] {
        
        return Dictionary(grouping: filteredAnnotations) {
            let dateString = $0.date.toString(with: .monthAndYear)
            guard let finalDate = dateString.toDate(with: .monthAndYear) else {
                return Date()
            }
            return finalDate
        }
    }
    
    private func getAnnotations(for key: Date) -> [PhotoMarkAnnotation]? {
        return annotationsGropedByDate?[key]?.sorted {
            $0.date > $1.date
        }
    }
}

extension TimelineViewController: Filterable {
    func filter(by choosedCategories: [Category]) {
        categories = choosedCategories
        getData()
    }
}

extension TimelineViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if isFiltering {
            return 1
        }
        return allDates?.count ?? 0
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
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if let firstVisibleIndexPath = tableView.indexPathsForVisibleRows?.first {
            if indexPath == firstVisibleIndexPath {
                let completion: () -> Void = {
                    [weak self] in
                    
                    guard let self = self else { return }
                    if self.refreshControl.isRefreshing {
                        self.refreshControl.endRefreshing()
                    }
                    print("TASKS FINISHED")
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 60, execute: completion)
                downloadGroup.notify(queue: .main, execute: completion)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "timelineCell", for: indexPath
        ) as! TimelineTableViewCell
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
        cell.photoImageView.image = .gifImageWithName("image_load")
        getImage(for: cell, with: annotation)
        cell.titleLabel.text = annotation.formattedTitle
        cell.dateLabel.text = "\(annotation.date.toString(with: .standart)) / \(annotation.category.asString.uppercased())"
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none
        return cell
    }
    
    private func getImage(for cell: TimelineTableViewCell, with annotation: PhotoMarkAnnotation) {
        downloadGroup.enter()
        AnnoationDownloader.getImage(url: annotation.imageURL, or: annotation.id) {
            [weak cell, weak self] image in
            
            if let image = image {
                cell?.photoImageView.image = image
            } else {
                cell?.photoImageView.image = #imageLiteral(resourceName: "image_error")
            }
            self?.downloadGroup.leave()
        }
    }
}

extension TimelineViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterContentForSearchText(searchBar.text!)
    }
    
    func filterContentForSearchText(_ searchText: String, category: Category? = nil) {
      
        filteredAnnotations = appDelegate.annotations.filter {
            (annotation: PhotoMarkAnnotation) -> Bool in
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
    
    private func getData() {
        self.groupData()
        self.tableView.reloadData()
    }
}
