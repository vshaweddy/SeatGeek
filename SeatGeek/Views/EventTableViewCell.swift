//
//  EventTableViewCell.swift
//  SeatGeek
//
//  Created by Vici Shaweddy on 2/20/21.
//

import UIKit

class EventTableViewCell: UITableViewCell {
    public static let reuseIdentifier = "EventCell"
    
    private lazy var mainStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layoutMargins = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
        view.isLayoutMarginsRelativeArrangement = true
        view.spacing = 4
        view.distribution = .equalSpacing
        view.alignment = .leading
        return view
    }()
    
    private lazy var verticalStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layoutMargins = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
        view.spacing = 4
        view.distribution = .equalSpacing
        view.alignment = .leading
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var thumbnailImage: UIImageView = {
        let thumbnaiImage = UIImageView()
        thumbnaiImage.translatesAutoresizingMaskIntoConstraints = false
        thumbnaiImage.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return thumbnaiImage
    }()
    
    func configureViews(event: EventRepresentation) {
        setupMainStackView()
        titleLabel.text = event.title
        subtitleLabel.text = event.venue.city
        
        guard let imageURL = event.performers.first?.image else { return }
        load(urlString: imageURL)
    }
    
    func load(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.thumbnailImage.image = image
                    }
                }
            }
        }
    }
    
    private func setupMainStackView() {
        contentView.addSubview(mainStackView)
        mainStackView.addArrangedSubview(thumbnailImage)
        mainStackView.addArrangedSubview(verticalStackView)
        verticalStackView.addArrangedSubview(titleLabel)
        verticalStackView.addArrangedSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}
