//
//  DetailViewController.swift
//  SeatGeek
//
//  Created by Vici Shaweddy on 2/28/21.
//

import UIKit

class DetailViewController: UIViewController {
    var event: EventRepresentation?
    
    private lazy var mainStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layoutMargins = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
        view.isLayoutMarginsRelativeArrangement = true
        view.spacing = 10
        view.distribution = .fill
        view.alignment = .leading
        return view
    }()
    
    private lazy var verticalStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layoutMargins = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
        view.spacing = 8
        view.distribution = .equalSpacing
        view.alignment = .fill
        return view
    }()
    
    private lazy var heroImage: UIImageView = {
        let thumbnaiImage = UIImageView()
        thumbnaiImage.translatesAutoresizingMaskIntoConstraints = false
        thumbnaiImage.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = false
        thumbnaiImage.layer.cornerRadius = 10
        thumbnaiImage.clipsToBounds = true
        thumbnaiImage.contentMode = .scaleAspectFill
        return thumbnaiImage
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 18.0)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var locationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14.0)
        label.textColor = .gray
        return label
    }()
    
    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM d, yyyy h:mm a"
        return dateFormatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMainStackView()
        
        if let event = event {
            guard let imageURL = event.performers.first?.image else { return }
            loadImage(urlString: imageURL)
            titleLabel.text = dateFormatter.string(from: event.date)
            locationLabel.text = "\(event.venue.city), \(event.venue.state)"
        }
        view.backgroundColor = .systemBackground
    }
    
    private func setupMainStackView() {
        view.addSubview(mainStackView)
        mainStackView.addArrangedSubview(verticalStackView)
        verticalStackView.addArrangedSubview(heroImage)
        verticalStackView.addArrangedSubview(titleLabel)
        verticalStackView.addArrangedSubview(locationLabel)
        
        NSLayoutConstraint.activate([
            mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mainStackView.topAnchor.constraint(equalTo: view.topAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func loadImage(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.heroImage.image = image
                    }
                }
            }
        }
    }
    
}
