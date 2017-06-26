//
//  ViewController.swift
//  Stationdata
//
//  Created by Beloizerov on 23.06.17.
//  Copyright © 2017 Beloizerov. All rights reserved.
//

import UIKit
import CoreData

final class ListViewController: UITableViewController, UISearchBarDelegate, NSFetchedResultsControllerDelegate, ListManagerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Locations".localized
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        //tableView
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = UITableViewAutomaticDimension
        tableView.register(ListCell.self, forCellReuseIdentifier: "ListCell")
        
        //refreshControl
        tableView.refreshControl = refreshController
        
        //searchButton
        navigationItem.rightBarButtonItem = searchButton
        
        //ListManager
        manager.delegate = self
        manager.fetchedResultsController.delegate = self
    }
    
    // MARK: - Pull to refresh
    
    private lazy var refreshController: UIRefreshControl = {
        let controller = UIRefreshControl()
        controller.attributedTitle = NSAttributedString(string: "Checking for updates".localized)
        controller.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return controller
    }()
    
    func refresh() {
        manager.updateLocationListFromServer()
    }
    
    // MARK: - ListManager
    
    private let manager = ListManager()
    
    func dataDidReload() {
        tableView.reloadData()
    }

    func listUpdated() {
        refreshControl?.endRefreshing()
    }
    
    // MARK: - UITableView Delegate and DataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return manager.fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell") as! ListCell
        let location = manager.fetchedResultsController.object(at: indexPath)
        cell.name = location.name
        configCell(cell: cell, with: location)
        cell.buttonTappedCallback = { [unowned self, weak cell] in
            guard let cell = cell, let indexPath = self.tableView.indexPath(for: cell) else { return }
            cell.animateDownloading()
            self.manager.downloadLocation(at: indexPath)
        }
        return cell
    }
    
    private func configCell(cell: ListCell, with location: Location) {
        switch manager.downloadingLocations.contains(location) {
        case true:
            cell.animateDownloading()
        case false:
            cell.config(with: location)
            guard let indexPath = indexPathToEnter else { break }
            tableView(tableView, didSelectRowAt: indexPath)
        }
    }
    
    private var indexPathToEnter: IndexPath?
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        indexPathToEnter = nil
        resighnSearchBar()
        let location = manager.fetchedResultsController.object(at: indexPath)
        switch location.downloadState {
        case .downloaded, .haveUpdate:
            let controller = DetailsViewController(location: location)
            navigationController?.pushViewController(controller, animated: true)
        case .notDownloaded:
            tableView.deselectRow(at: indexPath, animated: true)
            guard let cell = tableView.cellForRow(at: indexPath) as? ListCell else { return }
            indexPathToEnter = indexPath
            cell.animateDownloading()
            manager.downloadLocation(location)
        }
    }
    
    // MARK: SearchBar
    
    private lazy var searchButton: UIBarButtonItem = {
       return UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.search, target: self, action: #selector(searchButtonTapped))
    }()
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search".localized
        searchBar.delegate = self
        searchBar.returnKeyType = .done
        searchBar.enablesReturnKeyAutomatically = false
        return searchBar
    }()
    
    func searchButtonTapped() {
        searchBar.alpha = 0
        navigationItem.titleView = searchBar
        navigationItem.setRightBarButton(nil, animated: true)
        UIView.animate(withDuration: 0.5, animations: {
            self.searchBar.alpha = 1
        }, completion: { _ in
            self.searchBar.becomeFirstResponder()
        })
    }
    
    private func hideSearchBar() {
        indexPathToEnter = nil
        navigationItem.setRightBarButton(searchButton, animated: true)
        navigationItem.titleView = nil
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        indexPathToEnter = nil
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        indexPathToEnter = nil
        manager.refetchResults(name: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        resighnSearchBar()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        indexPathToEnter = nil
        manager.refetchResults(name: nil)
        searchBar.text = nil
        resighnSearchBar()
    }
    
    private func resighnSearchBar() {
        searchBar.resignFirstResponder()
        if searchBar.text?.isEmpty != false {
            hideSearchBar()
        } else {
            searchBar.setShowsCancelButton(false, animated: true)
        }
    }
    
    // MARK: NSFetchedResultsControllerDelegate
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let indexPath = newIndexPath else { break }
            tableView.insertRows(at: [indexPath], with: .fade)
        case .update:
            guard let indexPath = indexPath,
                let location = controller.object(at: indexPath) as? Location,
                let cell = tableView.cellForRow(at: indexPath) as? ListCell
                else { break }
            configCell(cell: cell, with: location)
        case .move:
            guard let indexPath = indexPath, let newIndexPath = newIndexPath else { break }
            tableView.moveRow(at: indexPath, to: newIndexPath)
        case .delete:
            guard let indexPath = indexPath else { break }
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
}

