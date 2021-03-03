//
//  EventController.swift
//  SeatGeek
//
//  Created by Vici Shaweddy on 2/21/21.
//

import CoreData
import Foundation

enum HTTPMethod: String {
  case get = "GET"
  case post = "POST"
  case put = "PUT"
  case delete = "DELETE"
}

enum NetworkError: Error {
  case noAuth
  case badAuth
  case otherError
  case badData
  case noDecode
}

struct EventsResponse: Codable {
  let events: [EventRepresentation]
}

final class EventController {
  private let session: URLSession
  private var baseURL = URLComponents(string: "https://api.seatgeek.com/2/events")!
  private let clientID = "MTQ0ODM5NXwxNjEzOTI1ODA1LjMwNzA3NzQ"
  private var events = [EventRepresentation]()

  /// Creates an instance of EventController
  ///
  /// - Parameter session: An optional session
  init(session: URLSession = URLSession.shared) {
    self.session = session
  }

  /// Fetch the events from SeatGeek API
  ///
  /// - Parameter completion: Completion handler
  func fetchEventsFromServer(
    completion: @escaping (Result<[EventRepresentation], NetworkError>) -> Void
  ) {
    baseURL.queryItems = [
      URLQueryItem(name: "client_id", value: clientID)
    ]

    guard let url = baseURL.url else { return }

    var request = URLRequest(url: url)
    request.httpMethod = HTTPMethod.get.rawValue

    session.dataTask(with: request) { (data, response, error) in
      if let response = response as? HTTPURLResponse,
        response.statusCode != 200
      {
        completion(.failure(.badAuth))
      }

      if error != nil {
        completion(.failure(.otherError))
      }

      guard let data = data else {
        completion(.failure(.badData))
        return
      }

      let decoder = JSONDecoder()
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
      decoder.dateDecodingStrategy = .formatted(dateFormatter)
      do {
        let eventResponse = try decoder.decode(EventsResponse.self, from: data)
        completion(.success(eventResponse.events))
      } catch {
        print("Error decoding events: \(error)")
        completion(.failure(.noDecode))
        return
      }
    }.resume()
  }

  /// Search with a query
  ///
  /// - Parameters:
  ///   - searchTerm: The search query
  ///   - completion: The completion handler
  func search(
    with searchTerm: String,
    completion: @escaping (Result<[EventRepresentation], NetworkError>) -> Void
  ) {
    baseURL.queryItems = [
      URLQueryItem(name: "client_id", value: clientID),
      URLQueryItem(name: "q", value: searchTerm),
    ]

    guard let url = baseURL.url else { return }

    var request = URLRequest(url: url)
    request.httpMethod = HTTPMethod.get.rawValue

    session.dataTask(with: request) { (data, response, error) in
      if let response = response as? HTTPURLResponse,
        response.statusCode != 200
      {
        completion(.failure(.badAuth))
      }

      if error != nil {
        completion(.failure(.otherError))
      }

      guard let data = data else {
        completion(.failure(.badData))
        return
      }

      let decoder = JSONDecoder()
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
      decoder.dateDecodingStrategy = .formatted(dateFormatter)
      do {
        let itemSearch = try decoder.decode(EventsResponse.self, from: data)
        completion(.success(itemSearch.events))
      } catch {
        print("Error decoding search results: \(error)")
        completion(.failure(.noDecode))
        return
      }
    }.resume()
  }

  /// Fetches the local favorite status for an event
  ///
  /// - Parameter event: The event object
  /// - Returns: A list of favorite events
  func fetchFavoriteStatus(for event: EventRepresentation) -> [FavoriteEvent] {
    let id = event.id
    let fetchRequest: NSFetchRequest<FavoriteEvent> = FavoriteEvent.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "%K == %i", "eventId", id)
    let context = CoreDataStack.shared.mainContext
    do {
      let favorites = try context.fetch(fetchRequest)
      return favorites
    } catch {
      print("Error fetching favorite")
      return []
    }
  }

  /// Fetches the user's local favorites
  ///
  /// - Returns: A list of favorite events
  func fetchFavorites() -> [FavoriteEvent] {
    let fetchRequest: NSFetchRequest<FavoriteEvent> = FavoriteEvent.fetchRequest()
    let context = CoreDataStack.shared.mainContext
    do {
      let favorites = try context.fetch(fetchRequest)
      return favorites
    } catch {
      print("Error fetching favorite")
      return []
    }
  }
}
