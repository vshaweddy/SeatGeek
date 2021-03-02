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
        view.layoutMargins = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        view.isLayoutMarginsRelativeArrangement = true
        view.spacing = 10
        view.distribution = .fillProportionally
        view.alignment = .leading
        return view
    }()
    
    private lazy var verticalStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layoutMargins = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        view.spacing = 8
        view.distribution = .equalSpacing
        view.alignment = .leading
        return view
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
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14.0)
        label.textColor = .gray
        return label
    }()
    
    private lazy var thumbnailImage: UIImageView = {
        let thumbnaiImage = UIImageView()
        thumbnaiImage.translatesAutoresizingMaskIntoConstraints = false
        thumbnaiImage.heightAnchor.constraint(equalToConstant: 80).isActive = true
        thumbnaiImage.widthAnchor.constraint(equalToConstant: 80).isActive = true
        thumbnaiImage.layer.cornerRadius = 10
        thumbnaiImage.clipsToBounds = true
        thumbnaiImage.contentMode = .scaleAspectFill
        return thumbnaiImage
    }()
    
    private lazy var favoriteIcon: UIImageView = {
        let icon = UIImageView(image: UIImage(systemName: "heart.fill"))
        icon.tintColor = .red
        icon.alpha = 0
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.widthAnchor.constraint(equalToConstant: 20).isActive = true
        
        return icon
    }()
    
    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM d, yyyy h:mm a"
        return dateFormatter
    }()
    
    override func prepareForReuse() {
        self.favoriteIcon.alpha = 0
        self.favoriteIcon.isHidden = true
    }
    
    func configureViews(event: EventRepresentation, isFavorite: Bool) {
        setupMainStackView()
        titleLabel.text = event.title
        locationLabel.text = "\(event.venue.city), \(event.venue.state)"
        
        favoriteIcon.isHidden = !isFavorite
        favoriteIcon.alpha = 1
        
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
    
    private func setupMainStackView() {
        contentView.addSubview(mainStackView)
        contentView.addSubview(favoriteIcon)
        mainStackView.addArrangedSubview(thumbnailImage)
        mainStackView.addArrangedSubview(verticalStackView)
        verticalStackView.addArrangedSubview(titleLabel)
        verticalStackView.addArrangedSubview(locationLabel)
        verticalStackView.addArrangedSubview(dateLabel)
        
        NSLayoutConstraint.activate([
            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            favoriteIcon.leadingAnchor.constraint(equalTo: thumbnailImage.leadingAnchor, constant: -8),
            favoriteIcon.topAnchor.constraint(equalTo: thumbnailImage.topAnchor, constant: -8)
        ])
    }
}
