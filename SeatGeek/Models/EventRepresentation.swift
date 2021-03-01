//
//  Event.swift
//  SeatGeek
//
//  Created by Vici Shaweddy on 2/21/21.
//

import CoreData
import Foundation

struct EventRepresentation: Codable {
    enum CodingKeys: String, CodingKey {
        case date = "datetime_local"
        case title
        case performers
        case venue
        case id
    }
    
    var date: Date
    var title: String
    var performers: [PerformerRepresentation]
    var venue: VenueRepresentation
    var id: Int64
}
