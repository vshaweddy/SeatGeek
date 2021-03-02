//
//  ViewController.swift
//  SeatGeek
//
//  Created by Vici Shaweddy on 2/20/21.
//

import CoreData
import UIKit

class MainViewController: UIViewController {
    var events = [EventRepresentation]()
    var searchResults = [EventRepresentation]()
    var isActive = false
    var eventController = EventController()
    var favoriteIdsSet = Set<Int64>()
    
    lazy var fetchedResultsController: NSFetchedResultsController<FavoriteEvent> = {
        let fetchRequest: NSFetchRequest<FavoriteEvent> = FavoriteEvent.fetchRequest()
        let sort = NSSortDescriptor(key: #keyPath(FavoriteEvent.eventId), ascending: true)
        fetchRequest.sortDescriptors = [sort]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.shared.mainContext, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchedResultsController
    }()

    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        configureSeachController()
        navigationBarColor()
        setupTableView()
        tableView.register(EventTableViewCell.self, forCellReuseIdentifier: EventTableViewCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        fetchedResultsController.delegate = self

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
        
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Fetching error: \(error), \(error.userInfo)")
        }
        
        if let fetchFavorites = fetchedResultsController.fetchedObjects {
            favoriteIdsSet = Set(fetchFavorites.map{ $0.eventId })
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
    
    private func navigationBarColor() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 34/255, green: 49/255, blue: 63/255, alpha: 1)
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.compactAppearance = appearance
    }
}

extension MainViewController: UITableViewDelegate {}

extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.isActive ? searchResults.count : events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: EventTableViewCell.reuseIdentifier, for: indexPath) as? EventTableViewCell else {
            fatalError()
        }
        
        let event = self.isActive ? searchResults[indexPath.row] : events[indexPath.row]
        let isFavorite = favoriteIdsSet.contains(event.id)
        cell.configureViews(event: event, isFavorite: isFavorite)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DetailViewController()
        vc.event = events[indexPath.row]
        vc.eventController = eventController
        navigationController?.pushViewController(vc, animated: true)
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

extension MainViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let fetchFavorites = controller.fetchedObjects as? [FavoriteEvent] else { return }
        favoriteIdsSet = Set(fetchFavorites.map { $0.eventId })
        tableView.reloadData()
    }
}
