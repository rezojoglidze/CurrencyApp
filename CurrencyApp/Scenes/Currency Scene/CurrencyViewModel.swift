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
    var pickerViewNumberOfRowsInComponent: Int { get }
    func pickerViewTitleForRow(row: Int) -> String
    
    var collectionViewNumberOfItems: Int { get }
    func getBalanceInfo(with index: Int) -> String
    
    func submitButtonTapped(amount: Decimal)
    
    var rateDidLoad: Observable<ExchangeEntity> { get }
    var showAlert: Observable<String> { get }
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
    var pickerViewNumberOfRowsInComponent: Int {
        Currency.allCases.count
    }
    
    func pickerViewTitleForRow(row: Int) -> String {
        Currency.allCases[row].rawValue
    }
    
    var collectionViewNumberOfItems: Int {
        Currency.allCases.count
    }
    
    func getBalanceInfo(with index: Int) -> String {
        let currency = Currency.allCases[index]
        return "\(balance[currency]?.stringValue(rounding: 1) ?? "") \(currency.rawValue.uppercased())"
    }
    
    func submitButtonTapped(amount: Decimal) {
        countCommissionFee(amount: amount)
        let totalAmount = amount + commissionFee
        
        if balance[currentSellCurrency] ?? 0 < totalAmount {
            innerShowAlertRelay.accept("Unfortunately, balance isn't enough.")
            return
        }
        
        let parameters: ExchangeGatewayParameters = .init(amount: amount, fromCurrency: currentSellCurrency.rawValue, toCurrency: currentSellCurrency.rawValue)
        calculateRates(with: parameters)
    }
    
    private func countCommissionFee(amount: Decimal) {
        if convertCount > 4 { //on the sixth convert convertCount value will be 5 because it increase when response comes.
            commissionFee = amount * commissionPercent
        }
    }
    
    private func calculateRates(
        with parameters: ExchangeGatewayParameters
    ) {
        ExchangeNetworkGateway().fetch(with: parameters, completion: { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let entity):
                self.innerRateDidLoad.accept(entity)
            case .failure(let error):
                self.innerShowAlertRelay.accept("Something happened. Please, Try again later.")
            }
        })
    }
}
