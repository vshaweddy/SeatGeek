//
//  Performer.swift
//  SeatGeek
//
//  Created by Vici Shaweddy on 2/21/21.
//

import Foundation

struct PerformerRepresentation: Codable {
    enum CodingKeys: String, CodingKey {
        case image
    }
    
    var image: String
}
