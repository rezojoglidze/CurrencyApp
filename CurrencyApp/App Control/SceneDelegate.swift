//
//  SceneDelegate.swift
//  CurrencyApp
//
//  Created by Rezo Joglidze on 03.01.23.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    // MARK: Properties
    var window: UIWindow?
    
    // MARK: Window Scene Delegate
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene: UIWindowScene = scene as? UIWindowScene else { return }
        
        window = .init(windowScene: windowScene)
        window?.rootViewController = createRootViewController()
        window?.overrideUserInterfaceStyle = .light
        window?.makeKeyAndVisible()
    }
    
    // MARK: Root View Controller
    func createRootViewController() -> UIViewController {
        CurrencyViewController.instantiate()
    }
}
