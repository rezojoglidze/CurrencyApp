//
//  MyBalancesCell.swift
//  CurrencyiOS
//
//  Created by Rezo Joglidze on 03.01.23.
//

import UIKit

class MyBalancesCell: UICollectionViewCell {
    
    @IBOutlet weak var amountWithCurrencyLbl: UILabel!
    
    func fill(text: String) {
        self.amountWithCurrencyLbl.text = text
    }
}
