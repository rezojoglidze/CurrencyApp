//
//  CurrencyEntity.swift
//  CurrencyApp
//
//  Created by Rezo Joglidze on 03.01.23.
//

import Foundation

// MARK: - Exchange Entity
struct ExchangeEntity: Codable {
    // MARK: Properties
    let amount: String
    let currency: String
    
    // MARK: Coding Keys
    private enum CodingKeys: String, CodingKey {
        case amount, currency
    }
}
