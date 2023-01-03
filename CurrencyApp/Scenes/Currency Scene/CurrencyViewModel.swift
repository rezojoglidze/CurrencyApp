//
//  CurrencyViewModel.swift
//  CurrencyiOS
//
//  Created by Rezo Joglidze on 03.01.23.
//

import Foundation

protocol CurrencyViewModel {
    var pickerViewNumberOfRowsInComponent: Int { get }
    func pickerViewTitleForRow(row: Int) -> String
    
    var collectionViewNumberOfItems: Int { get }
}

final class DefaultCurrencyViewModel {

}

extension DefaultCurrencyViewModel: CurrencyViewModel {
    var pickerViewNumberOfRowsInComponent: Int {
        Currency.allCases.count
    }
    
    func pickerViewTitleForRow(row: Int) -> String {
        Currency.allCases[row].rawValue
    }
    
    var collectionViewNumberOfItems: Int {
        Currency.allCases.count
    }
}
