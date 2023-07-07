//
//  DownloadAnimationView.swift
//  ToDoList
//
//  Created by Даниил Кизельштейн on 07.07.2023.
//

import UIKit

class DownloadAnimationView: UIView {

    lazy var firstCircle = UIView()
    lazy var secondCircle = UIView()
    lazy var thirdCircle = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        configureFirstCircle()
        configureSecondCircle()
        configureThirdCircle()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        configureFirstCircle()
        configureSecondCircle()
        configureThirdCircle()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        firstCircle.layer.cornerRadius = firstCircle.bounds.width/2
        secondCircle.layer.cornerRadius = secondCircle.bounds.width/2
        thirdCircle.layer.cornerRadius = thirdCircle.bounds.width/2
    }

    private func configureFirstCircle() {
        firstCircle.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(firstCircle)

        NSLayoutConstraint.activate([
            firstCircle.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            firstCircle.topAnchor.constraint(equalTo: self.topAnchor),
            firstCircle.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            firstCircle.widthAnchor.constraint(equalToConstant: 20)
        ])
    }

    private func configureSecondCircle() {
        secondCircle.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(secondCircle)

        NSLayoutConstraint.activate([
            secondCircle.leadingAnchor.constraint(equalTo: firstCircle.trailingAnchor),
            secondCircle.topAnchor.constraint(equalTo: self.topAnchor),
            secondCircle.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            secondCircle.widthAnchor.constraint(equalTo: firstCircle.widthAnchor)
        ])
    }

    private func configureThirdCircle() {
        thirdCircle.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(thirdCircle)

        NSLayoutConstraint.activate([
            thirdCircle.leadingAnchor.constraint(equalTo: secondCircle.trailingAnchor),
            thirdCircle.topAnchor.constraint(equalTo: self.topAnchor),
            thirdCircle.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            thirdCircle.widthAnchor.constraint(equalTo: secondCircle.widthAnchor)
        ])
    }

}
