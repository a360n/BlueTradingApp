//
//  Trade.swift
//  BlueTradingApp
//
//  Created by Ali Al-Khazali on 7/7/25.
//

import Foundation

struct Trade: Identifiable, Codable {
    let id: UUID
    let type: String   // "BUY", "SELL"
    let price: String
    let date: Date

    init(id: UUID = UUID(), type: String, price: String, date: Date) {
        self.id = id
        self.type = type
        self.price = price
        self.date = date
    }
}
