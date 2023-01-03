//
//  UIViewController.Keyboard.swift
//  CurrencyApp
//
//  Created by Rezo Joglidze on 03.01.23.
//

import UIKit

// MARK: - Dismiss Keyboard On Outside Tap
extension UIViewController {
    func dismissKeyboardOnOutsideTap() {
        view.addGestureRecognizer({
            let gesture: UITapGestureRecognizer = .init(target: self, action: #selector(endEditingFromOutsideTap))
            gesture.cancelsTouchesInView = false
            return gesture
        }())
    }

    @objc private func endEditingFromOutsideTap() {
        view.endEditing(true)
    }
}
