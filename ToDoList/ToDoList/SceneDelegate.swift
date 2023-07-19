//
//  SceneDelegate.swift
//  ToDoList
//
//  Created by Даниил Кизельштейн on 12.06.2023.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        window?.windowScene = windowScene
        window?.makeKeyAndVisible()

        let viewController = ItemsListViewController()
        let navViewController = UINavigationController(rootViewController: viewController)
        window?.rootViewController = navViewController
    }

    func sceneDidDisconnect(_ scene: UIScene) {}

    func sceneDidBecomeActive(_ scene: UIScene) {}

    func sceneWillResignActive(_ scene: UIScene) {}

    func sceneWillEnterForeground(_ scene: UIScene) {}

    func sceneDidEnterBackground(_ scene: UIScene) {}
}
