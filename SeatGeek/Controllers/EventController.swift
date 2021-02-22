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
               response.statusCode != 403 {
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
}