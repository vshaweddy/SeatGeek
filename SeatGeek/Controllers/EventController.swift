//
//  EventController.swift
//  SeatGeek
//
//  Created by Vici Shaweddy on 2/21/21.
//

import Foundation
import CoreData

private struct EventsResponse: Decodable {
    let events: [EventRepresentation]
}

class EventController {
    private var baseURL = URLComponents(string: "https://api.seatgeek.com/2/events")!
    private let clientID = "MTQ0ODM5NXwxNjEzOTI1ODA1LjMwNzA3NzQ"
    var events = [EventRepresentation]()
    
    func fetchEventsFromServer(completion: @escaping (Result<[EventRepresentation], NetworkError>) -> Void) {
        baseURL.queryItems = [
            URLQueryItem(name: "client_id", value: clientID)
        ]
        
        guard let url = baseURL.url else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let response = response as? HTTPURLResponse,
               response.statusCode != 200 {
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
    
    func searchQuery(with searchTerm: String, completion: @escaping (Result<[EventRepresentation], NetworkError>) -> Void) {
        baseURL.queryItems = [
            URLQueryItem(name: "client_id", value: clientID),
            URLQueryItem(name: "q", value: searchTerm)
        ]
        
        guard let url = baseURL.url else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let response = response as? HTTPURLResponse,
               response.statusCode != 200 {
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
