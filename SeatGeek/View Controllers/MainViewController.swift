//
//  ViewController.swift
//  SeatGeek
//
//  Created by Vici Shaweddy on 2/20/21.
//

import UIKit

class MainViewController: UIViewController {
    var events = [EventRepresentation]()
    var eventController = EventController()
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
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

                break
            case .failure(let error):
                print(error)
                break
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
        return events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: EventTableViewCell.reuseIdentifier, for: indexPath) as? EventTableViewCell else {
            fatalError()
        }
        
        cell.configureViews(event: events[indexPath.row])
        
        return cell
    }
}
