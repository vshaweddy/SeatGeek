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
        view.distribution = .fillProportionally
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
    
    private lazy var locationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var thumbnailImage: UIImageView = {
        let thumbnaiImage = UIImageView()
        thumbnaiImage.translatesAutoresizingMaskIntoConstraints = false
        thumbnaiImage.heightAnchor.constraint(equalToConstant: 80).isActive = true
        thumbnaiImage.widthAnchor.constraint(equalToConstant: 80).isActive = true
        thumbnaiImage.layer.cornerRadius = 10
        thumbnaiImage.clipsToBounds = true
        return thumbnaiImage
    }()
    
    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM d, yyyy h:mm a"
        return dateFormatter
    }()
    
    func configureViews(event: EventRepresentation) {
        setupMainStackView()
        titleLabel.text = event.title
        locationLabel.text = "\(event.venue.city), \(event.venue.state)"

        
        guard let imageURL = event.performers.first?.image else { return }
        loadImage(urlString: imageURL)
        
        dateLabel.text = dateFormatter.string(from: event.date)
    }
    
    func loadImage(urlString: String) {
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
    
//    func scaleImage(_ image: UIImage) {
//        guard let image = image else { return }
//        let targetSize = CGSize(width: 100, height: 100)
//
//        let widthScaleRatio = targetSize.width / image.size.width
//        let heightScaleRatio = targetSize.height / image.size.height
//
//        let scaleFactor = min(widthScaleRatio, heightScaleRatio)
//
//        let
//    }
    
    private func setupMainStackView() {
        contentView.addSubview(mainStackView)
        mainStackView.addArrangedSubview(thumbnailImage)
        mainStackView.addArrangedSubview(verticalStackView)
        verticalStackView.addArrangedSubview(titleLabel)
        verticalStackView.addArrangedSubview(locationLabel)
        verticalStackView.addArrangedSubview(dateLabel)
        
        NSLayoutConstraint.activate([
            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}
