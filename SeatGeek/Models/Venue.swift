//
//  Venue.swift
//  SeatGeek
//
//  Created by Vici Shaweddy on 2/21/21.
//

import Foundation

struct VenueRepresentation: Codable {
    enum CodingKeys: String, CodingKey {
        case city
        case state
    }
    
    let city: String
    let state: String
}
