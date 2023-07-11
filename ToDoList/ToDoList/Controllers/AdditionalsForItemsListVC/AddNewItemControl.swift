//
//  AddNewItemControl.swift
//  ToDoList
//
//  Created by Даниил Кизельштейн on 29.06.2023.
//

import UIKit

@MainActor
protocol NewItemThroughCircleAddable: AnyObject {
    func addNewItemThroughCircle()
}

class AddNewItemControl: UIControl {

    private lazy var addNewItemImageView: UIImageView = {
        let addNewItemImageView = UIImageView()
        addNewItemImageView.image = UIImage(
            systemName: "plus.circle.fill")?.withTintColor(
                Colors.colorBlue.value,
                renderingMode: .alwaysOriginal)
        return addNewItemImageView
    }()

    weak var delegate: NewItemThroughCircleAddable?

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .clear

        configureAddNewItemImageView()
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(addNewItem))
        self.addGestureRecognizer(tapGR)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        backgroundColor = .clear

        configureAddNewItemImageView()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        addNewItemImageView.layer.cornerRadius = 22
        addNewItemImageView.layer.shadowRadius = 16
        addNewItemImageView.layer.shadowOpacity = 0.2
        addNewItemImageView.layer.shadowColor = UIColor.black.cgColor
    }

    private func configureAddNewItemImageView() {
        addNewItemImageView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(addNewItemImageView)

        NSLayoutConstraint.activate([
            addNewItemImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            addNewItemImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            addNewItemImageView.topAnchor.constraint(equalTo: self.topAnchor),
            addNewItemImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }

    @objc private func addNewItem() {
        delegate?.addNewItemThroughCircle()
    }

}
