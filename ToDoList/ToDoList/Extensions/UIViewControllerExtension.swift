//
//  UIViewControllerExtension.swift
//  ToDoList
//
//  Created by Даниил Кизельштейн on 07.07.2023.
//

import UIKit

extension UIViewController {
    func show(message: String) {
        let alertVC = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)

        alertVC.addAction(okAction)
        present(alertVC, animated: true)
    }
}
