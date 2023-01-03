//
//  UIViewController.Alert.swift
//  CurrencyApp
//
//  Created by Rezo Joglidze on 03.01.23.
//

import UIKit

// MARK: - Alert
extension UIViewController {
    func showAlert(title: String = "", text: String) {
        let alert = UIAlertController(title: title, message: text, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
        alert.addAction(alertAction)
        self.present(alert, animated: true, completion: nil)
    }
}
