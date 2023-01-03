//
//  ViewController.swift
//  CurrencyiOS
//
//  Created by Rezo Joglidze on 03.01.23.
//

import UIKit

class CurrencyViewController: UIViewController {
    
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var myBalanceCollectionView: UICollectionView!
    @IBOutlet private weak var buyCurrencyAmountLabel: UILabel!
    @IBOutlet private weak var sellCurrencyAmountTextField: UITextField!
    @IBOutlet private weak var sellButton: UIButton!
    @IBOutlet private weak var buyButton: UIButton!
    @IBOutlet private weak var submitButton: UIButton!
    @IBOutlet private weak var scrollViewBottomLayout: NSLayoutConstraint!
    
    static func instantiate() -> CurrencyViewController {
        let storyBoard = UIStoryboard(name: "Currency", bundle: nil)
        let viewController = storyBoard.instantiateViewController(withIdentifier: "CurrencyViewController") as? CurrencyViewController ?? .init()
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}
