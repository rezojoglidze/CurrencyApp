//
//  ExchangeNetworkGateway.swift
//  CurrencyApp
//
//  Created by Rezo Joglidze on 03.01.23.
//

import Foundation

// MARK: - Exchange Network Gateway
struct ExchangeNetworkGateway: ExchangeGateway {
    func fetch(
        with parameters: ExchangeGatewayParameters,
        completion: @escaping (Result<ExchangeEntity, any Error>) -> Void
    ) {
        guard let url = URL(string: "http://api.evp.lt/currency/commercial/exchange/\(parameters.amount)-\(parameters.fromCurrency)/\(parameters.toCurrency)/latest") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                let jsonDecoder = JSONDecoder()
                do {
                    let exchange = try jsonDecoder.decode(ExchangeEntity.self, from: data)
                    completion(.success(exchange))
                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}
