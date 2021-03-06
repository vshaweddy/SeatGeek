//
//  DetailViewController.swift
//  SeatGeek
//
//  Created by Vici Shaweddy on 2/28/21.
//

import CoreData
import UIKit

class DetailViewController: UIViewController {
  private var favorite: FavoriteEvent? {
    didSet {
      let image = favorite == nil ? "heart" : "heart.fill"
      favoriteButton.setImage(UIImage(systemName: image), for: .normal)
    }
  }

  private lazy var mainStackView: UIStackView = {
    let view = UIStackView()
    view.axis = .vertical
    view.translatesAutoresizingMaskIntoConstraints = false
    view.layoutMargins = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
    view.isLayoutMarginsRelativeArrangement = true
    view.spacing = 10
    return view
  }()

  private lazy var horizontalStackView: UIStackView = {
    let view = UIStackView()
    view.axis = .horizontal
    view.translatesAutoresizingMaskIntoConstraints = false
    view.isLayoutMarginsRelativeArrangement = true
    view.layoutMargins = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
    view.spacing = 8
    view.distribution = .fill
    view.alignment = .leading
    return view
  }()

  private lazy var verticalStackView: UIStackView = {
    let view = UIStackView()
    view.axis = .vertical
    view.translatesAutoresizingMaskIntoConstraints = false
    view.spacing = 8
    view.distribution = .fillProportionally
    view.alignment = .fill
    return view
  }()

  private lazy var backButton: UIButton = {
    let backButton = UIButton()
    backButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    backButton.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
    return backButton
  }()

  private lazy var favoriteButton: UIButton = {
    let favoriteButton = UIButton()
    favoriteButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
    favoriteButton.tintColor = .red
    return favoriteButton
  }()

  private lazy var separatorLine: UIView = {
    let line = UIView()
    line.backgroundColor = UIColor(red: 228 / 255, green: 233 / 255, blue: 237 / 255, alpha: 2)
    line.heightAnchor.constraint(equalToConstant: 1).isActive = true
    line.translatesAutoresizingMaskIntoConstraints = false
    return line
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

  private lazy var navigationTitleLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = UIFont.boldSystemFont(ofSize: 18.0)
    label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    label.numberOfLines = 0
    return label
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

  // The event passed from main
  var event: EventRepresentation?

  // The event controller passed from main
  var eventController: EventController?

  override func viewDidLoad() {
    super.viewDidLoad()
    setupMainStackView()
    navigationController?.navigationBar.isHidden = true
    self.navigationItem.setHidesBackButton(true, animated: true)
    favoriteButton.addAction(
      UIAction(handler: { [weak self] _ in
        self?.favoriteTapped()
      }), for: .primaryActionTriggered)

    backButton.addAction(
      UIAction(handler: { [weak self] _ in
        self?.backButtonTapped()
      }), for: .primaryActionTriggered)

    if let event = event {
      guard let imageURL = event.performers.first?.image else { return }
      loadImage(urlString: imageURL)
      titleLabel.text = dateFormatter.string(from: event.date)
      locationLabel.text = "\(event.venue.city), \(event.venue.state)"
      navigationTitleLabel.text = event.title
      favorite = eventController?.fetchFavoriteStatus(for: event).first
    }
    view.backgroundColor = .systemBackground
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    navigationController?.navigationBar.isHidden = false
  }

  // MARK: - Private

  private func favoriteTapped() {
    let context = CoreDataStack.shared.mainContext
    if let favorite = favorite {
      context.delete(favorite)
      self.favorite = nil
    } else {
      guard let id = event?.id else { return }
      let favoriteEvent = FavoriteEvent(context: context)
      favoriteEvent.eventId = id
      self.favorite = favoriteEvent
    }

    do {
      try context.save()
    } catch {
      print(error)
    }
  }

  private func backButtonTapped() {
    navigationController?.popToRootViewController(animated: true)
  }

  private func setupMainStackView() {
    view.addSubview(mainStackView)
    mainStackView.addArrangedSubview(horizontalStackView)
    mainStackView.addArrangedSubview(separatorLine)

    horizontalStackView.addArrangedSubview(backButton)
    horizontalStackView.addArrangedSubview(navigationTitleLabel)
    horizontalStackView.addArrangedSubview(favoriteButton)

    mainStackView.addArrangedSubview(verticalStackView)
    verticalStackView.addArrangedSubview(heroImage)
    verticalStackView.addArrangedSubview(titleLabel)
    verticalStackView.addArrangedSubview(locationLabel)

    NSLayoutConstraint.activate([
      mainStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      mainStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      mainStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),

      separatorLine.leadingAnchor.constraint(equalTo: mainStackView.leadingAnchor, constant: 12),
      separatorLine.trailingAnchor.constraint(equalTo: mainStackView.trailingAnchor, constant: -12),

      horizontalStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      horizontalStackView.trailingAnchor.constraint(
        equalTo: view.safeAreaLayoutGuide.trailingAnchor),

      verticalStackView.leadingAnchor.constraint(
        equalTo: mainStackView.leadingAnchor, constant: 12),
      verticalStackView.trailingAnchor.constraint(
        equalTo: mainStackView.trailingAnchor, constant: -12),
    ])
  }

  private func loadImage(urlString: String) {
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
