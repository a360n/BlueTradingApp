//
//  PricePoint.swift
//  BlueTradingApp
//
//  Created by Ali Al-Khazali on 7/8/25.
//

import Foundation
struct PricePoint: Identifiable, Codable {
    var id: UUID { UUID() }
    let timestamp: Date
    let price: Double
}
