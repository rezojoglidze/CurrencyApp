//
//  MyBalancesCell.swift
//  CurrencyiOS
//
//  Created by Rezo Joglidze on 05.03.22.
//

import UIKit

class MyBalancesCell: UICollectionViewCell {
    
    @IBOutlet weak var amountWithCurrencyLbl: UILabel!
    
    func fill(text: String) {
        self.amountWithCurrencyLbl.text = text
    }
}
