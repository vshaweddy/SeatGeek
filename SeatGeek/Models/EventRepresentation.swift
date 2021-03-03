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

  let date: Date
  let title: String
  let performers: [PerformerRepresentation]
  let venue: VenueRepresentation
  let id: Int64
}
