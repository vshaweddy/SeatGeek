//
//  ViewController.swift
//  SeatGeek
//
//  Created by Vici Shaweddy on 2/20/21.
//

import UIKit

class MainViewController: UIViewController {
    var events = [EventRepresentation]()
    var searchResults = [EventRepresentation]()
    var isActive = false
    var eventController = EventController()
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        configureSeachController()
        setupTableView()
        tableView.register(EventTableViewCell.self, forCellReuseIdentifier: EventTableViewCell.reuseIdentifier)
        tableView.dataSource = self

        eventController.fetchEventsFromServer { [weak self] result in
            switch result {
            case .success(let events):
                self?.events = events
                
                DispatchQueue.main.async { [weak self] in
                    self?.tableView.reloadData()
                }

            case .failure(let error):
                print(error)
            }
        }
    }
}

extension MainViewController {
    private func setupTableView() {
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func configureViewController() {
        view.backgroundColor = .systemBackground
    }
}

extension MainViewController: UITableViewDelegate {
    
}

extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.isActive ? searchResults.count : events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: EventTableViewCell.reuseIdentifier, for: indexPath) as? EventTableViewCell else {
            fatalError()
        }
        
        let event = self.isActive ? searchResults[indexPath.row] : events[indexPath.row]
        
        cell.configureViews(event: event)
        
        return cell
    }
}

extension MainViewController {
    func configureSeachController() {
        let searchController = UISearchController()
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search"
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
    }
}

extension MainViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if searchController.isActive {
            guard let text = searchController.searchBar.text, !text.isEmpty else {
                self.isActive = false
                self.tableView.reloadData()
                return
            }
            
            self.isActive = true
            eventController.searchQuery(with: text) { [weak self] result in
                switch result {
                case .success(let results):
                    self?.searchResults = results
                    
                    DispatchQueue.main.async { [weak self] in
                        self?.tableView.reloadData()
                    }

                case .failure(let error):
                    print(error)
                }
            }
        } else {
            self.isActive = false
            tableView.reloadData()
        }
    }
}
