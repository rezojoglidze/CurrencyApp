//
//  BalanceCell.swift
//  CurrencyiOS
//
//  Created by Rezo Joglidze on 03.01.23.
//

import UIKit

class BalanceCell: UICollectionViewCell {
    // MARK: IBOutlets
    @IBOutlet private weak var amountLabel: UILabel!
    
    //MARK: Methods
    func fill(text: String) {
        amountLabel.text = text
    }
}
