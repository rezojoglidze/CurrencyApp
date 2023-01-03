//
//  Decimal.Rounding.swift
//  CurrencyApp
//
//  Created by Rezo Joglidze on 03.01.23.
//

import Foundation

// MARK: - Rounding Decimal Value
extension Decimal {
    func stringValue(rounding: Int = 2) -> String {
        let formatter = NumberFormatter()
        formatter.generatesDecimalNumbers = true
        formatter.minimumFractionDigits = rounding
        formatter.maximumFractionDigits = rounding
        return formatter.string(from: self as NSDecimalNumber) ?? ""
    }
}
