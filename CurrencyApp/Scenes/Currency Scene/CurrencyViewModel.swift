//
//  CurrencyViewModel.swift
//  CurrencyiOS
//
//  Created by Rezo Joglidze on 03.01.23.
//

import Foundation
import RxSwift
import RxCocoa
 
//MARK: Currency View Model
protocol CurrencyViewModel {
    var rateDidLoad: Observable<ExchangeEntity> { get }
    var showAlert: Observable<String> { get }
    
    var pickerViewNumberOfRowsInComponent: Int { get }
    func pickerViewTitleForRow(row: Int) -> String
    
    var collectionViewNumberOfItems: Int { get }
    func getBalanceInfo(with index: Int) -> String
    
    var isSell: Bool { get set }
    func getSelectedCurrency(row: Int) -> Currency
    func submitButtonTapped(amount: Decimal)
}

//MARK: Default Currency View Model
final class DefaultCurrencyViewModel {
    //MARK: Properties
    var rateDidLoad: Observable<ExchangeEntity>
    var showAlert: Observable<String>
    private let innerRateDidLoad: PublishRelay<ExchangeEntity> = PublishRelay<ExchangeEntity>()
    private let innerShowAlertRelay: PublishRelay<String> = PublishRelay<String>()

    private var balance: [Currency: Decimal] = [
        .eur: 1000,
        .usd: 0,
        .jpy: 0
    ]
    
    var isSell: Bool = false
    private var currentSellCurrency: Currency = .eur
    private var currentBuyCurrency: Currency = .usd
    private var availableBuyCurrencies: [Currency] = []
    private var availableSellCurrencies: [Currency] = []
    private let commissionPercent: Decimal = 7/100
    private var commissionFee: Decimal = 0
    
    private let threadSafeCountQueue = DispatchQueue(label: "com.joglidze.CurrencyApp")
    private var _convertCount = 0
    private var convertCount: Int {
        get {
            return threadSafeCountQueue.sync {
                _convertCount
            }
        }
        set {
            threadSafeCountQueue.sync {
                _convertCount = newValue
            }
        }
    }
    
    // MARK: Initializers
    init() {
        self.rateDidLoad = self.innerRateDidLoad.asObservable()
        self.showAlert = self.innerShowAlertRelay.asObservable()
    }
}

extension DefaultCurrencyViewModel: CurrencyViewModel {
    //MARK: Currency View Model Protocol
    var pickerViewNumberOfRowsInComponent: Int {
        getPickerViewNumberOfRowsInComponent()
    }
    
    func pickerViewTitleForRow(row: Int) -> String {
        isSell ? availableSellCurrencies[row].rawValue : availableBuyCurrencies[row].rawValue
    }
    
    var collectionViewNumberOfItems: Int {
        Currency.allCases.count
    }
    
    func getBalanceInfo(with index: Int) -> String {
        let currency = Currency.allCases[index]
        return "\(balance[currency]?.stringValue(rounding: 1) ?? "") \(currency.rawValue.uppercased())"
    }
    
    func getSelectedCurrency(row: Int) -> Currency {
        let currency = isSell ? availableSellCurrencies[row] : availableBuyCurrencies[row]
        isSell ? (currentSellCurrency = currency) : (currentBuyCurrency = currency)
        return currency
    }
    
    func submitButtonTapped(amount: Decimal) {
        countCommissionFee(amount: amount)
        
        let totalAmount = amount + commissionFee
        if balance[currentSellCurrency] ?? 0 < totalAmount {
            innerShowAlertRelay.accept("Unfortunately, balance isn't enough.")
            return
        }
        
        let parameters: ExchangeGatewayParameters = .init(amount: amount, fromCurrency: currentSellCurrency.rawValue, toCurrency: currentBuyCurrency.rawValue)
        calculateRate(with: parameters)
    }
    
    // MARK: Requests
    private func calculateRate(
        with parameters: ExchangeGatewayParameters
    ) {
        ExchangeNetworkGateway().fetch(with: parameters, completion: { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let entity):
                self.convertCount += 1
                self.innerShowAlertRelay.accept(self.getSuccessCalculatedRateText(amount: parameters.amount, entity: entity))
                self.innerRateDidLoad.accept(entity)
                self.updateBalance(parameters.amount, entity)
            case .failure(let error):
                print(error.localizedDescription)
                self.innerShowAlertRelay.accept("Something happened. Please, Try again later.")
            }
        })
    }
    
    //MARK: Helper Methods
    private func getPickerViewNumberOfRowsInComponent() -> Int {
        filterAvailableCurrencies()
        let currencies = isSell ? availableSellCurrencies : availableBuyCurrencies
        return currencies.count
    }
    
    private func filterAvailableCurrencies() {
        let currentCurrency = isSell ? currentSellCurrency: currentBuyCurrency
        let currencies =  Currency.allCases.filter { currency in
            return currency != currentCurrency
        }
        
        isSell ? (availableSellCurrencies = currencies) : (availableBuyCurrencies = currencies)
    }
    
    private func countCommissionFee(amount: Decimal) {
        if convertCount > 4 {
            commissionFee = amount * commissionPercent
        }
    }
    
    private func updateBalance(
        _ amount: Decimal,
        _ entity: ExchangeEntity
    ) {
        guard let currentSellCurrencyBalance = balance[currentSellCurrency],
              let currentBuyCurrencyBalance = balance[currentBuyCurrency],
              let inputedAmount = Decimal(string: entity.amount) else { return }
        
        balance[currentSellCurrency] = currentSellCurrencyBalance - (amount + commissionFee)
        balance[currentBuyCurrency] = currentBuyCurrencyBalance + inputedAmount
    }
    
    private func getSuccessCalculatedRateText(
        amount: Decimal,
        entity: ExchangeEntity
    ) -> String {
        return "You have converted \(amount) \(currentSellCurrency.rawValue) to \(entity.amount) \(entity.currency). Commission Fee - \(commissionFee.stringValue())  \(currentSellCurrency.rawValue)"
    }
}
