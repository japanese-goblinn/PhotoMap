//
//  TimelineViewController.swift
//  PhotoMap
//
//  Created by Kiryl Harbachonak on 10/9/19.
//  Copyright © 2019 Kiryl Harbachonak. All rights reserved.
//

import UIKit
import CoreLocation

class TimelineViewController: UIViewController {
    
    private var categories = Category.allCases
    private var annotations = [PhotoMarkAnnotation]()
    private var filteredAnnotations = [PhotoMarkAnnotation]()
    private var annotationsGropedByDate: [Date: [PhotoMarkAnnotation]]?
    private var allDates: [Date]?
    
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
        initTestData()
        getData()
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
    
    private func getData() {
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
        getData()
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
    private func initTestData() {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        annotations.append(
            PhotoMarkAnnotation(
                title: "Some title #hot",
                date: formatter.date(from: "28/01/2019") ?? Date(),
                image: #imageLiteral(resourceName: "test_image"),
                coordinate: CLLocationCoordinate2D(
                    latitude: .leastNonzeroMagnitude, longitude: .leastNonzeroMagnitude
                ),
                category: .friends
            )
        )
        annotations.append(
            PhotoMarkAnnotation(
                title: "Some like very long title that can't fit in label",
                date: formatter.date(from: "18/01/2019") ?? Date(),
                image: #imageLiteral(resourceName: "test_image"),
                coordinate: CLLocationCoordinate2D(
                    latitude: .leastNonzeroMagnitude, longitude: .leastNonzeroMagnitude
                ),
                category: .friends
            )
        )
        annotations.append(
            PhotoMarkAnnotation(
                title: "Some title",
                date: formatter.date(from: "28/02/2019") ?? Date(),
                image: #imageLiteral(resourceName: "test_image"),
                coordinate: CLLocationCoordinate2D(
                    latitude: .leastNonzeroMagnitude, longitude: .leastNonzeroMagnitude
                ),
                category: .nature
            )
        )
        annotations.append(
            PhotoMarkAnnotation(
                title: "Some title",
                date: formatter.date(from: "28/10/2018") ?? Date(),
                image: #imageLiteral(resourceName: "test_image"),
                coordinate: CLLocationCoordinate2D(
                    latitude: .leastNonzeroMagnitude, longitude: .leastNonzeroMagnitude
                ),
                category: .uncategorized
            )
        )
        annotations.append(
            PhotoMarkAnnotation(
                title: "Some title",
                date: formatter.date(from: "14/01/2020") ?? Date(),
                image: #imageLiteral(resourceName: "test_image"),
                coordinate: CLLocationCoordinate2D(
                    latitude: .leastNonzeroMagnitude, longitude: .leastNonzeroMagnitude
                ),
                category: .uncategorized
            )
        )
        annotations.append(
            PhotoMarkAnnotation(
                title: "Some title",
                date: formatter.date(from: "10/10/2019") ?? Date(),
                image: #imageLiteral(resourceName: "test_image"),
                coordinate: CLLocationCoordinate2D(
                    latitude: .leastNonzeroMagnitude, longitude: .leastNonzeroMagnitude
                ),
                category: .uncategorized
            )
        )
        annotations.append(
            PhotoMarkAnnotation(
                title: nil,
                date: formatter.date(from: "14/01/2017") ?? Date(),
                image: #imageLiteral(resourceName: "test_image"),
                coordinate: CLLocationCoordinate2D(
                    latitude: .leastNonzeroMagnitude, longitude: .leastNonzeroMagnitude
                ),
                category: .uncategorized
            )
        )
    }
}
