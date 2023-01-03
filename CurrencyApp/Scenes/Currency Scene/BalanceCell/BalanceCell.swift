//
//  BalanceCell.swift
//  CurrencyiOS
//
//  Created by Rezo Joglidze on 03.01.23.
//

import UIKit

class BalanceCell: UICollectionViewCell {
    
    // MARK: IBOutlets
    @IBOutlet weak var amountWithCurrencyLbl: UILabel!
    
    //MARK: Methods
    func fill(text: String) {
        self.amountWithCurrencyLbl.text = text
    }
}
