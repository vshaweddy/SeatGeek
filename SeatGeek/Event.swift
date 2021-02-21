//
//  Event.swift
//  SeatGeek
//
//  Created by Vici Shaweddy on 2/21/21.
//

import Foundation

struct Event {
    enum CodingKeys: String, CodingKey {
        case title
        case venue
        case date = "datetime_local"
    }
    
    let title: String
    let venue: [Venue]
    let date: String
    let performer: [Performer]
}
