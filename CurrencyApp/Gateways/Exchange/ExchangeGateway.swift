//
//  ExchangeGateway.swift
//  CurrencyApp
//
//  Created by Rezo Joglidze on 03.01.23.
//

import Foundation

// MARK: - Exchange Gateway
protocol ExchangeGateway {
    func fetch(
        with parameters: ExchangeGatewayParameters,
        completion: @escaping (Result<ExchangeEntity, any Error>) -> Void
    )
}
