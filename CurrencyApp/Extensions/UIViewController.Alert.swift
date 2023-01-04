//
//  UIViewController.Alert.swift
//  CurrencyApp
//
//  Created by Rezo Joglidze on 03.01.23.
//

import UIKit

// MARK: - Alert
extension UIViewController {
    func showAlert(
        title: String = "",
        message: String,
        preferredStyle: UIAlertController.Style = .alert,
        completion: (() -> Void)? = nil,
        alertAction: ((UIAlertAction) -> Void)? = nil
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: alertAction))
        self.present(alert, animated: true, completion: completion)
    }
}
