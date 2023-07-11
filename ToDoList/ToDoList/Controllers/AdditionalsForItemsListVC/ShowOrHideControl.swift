//
//  ShowOrHideControl.swift
//  ToDoList
//
//  Created by Даниил Кизельштейн on 27.06.2023.
//

import UIKit

enum ShowAction {
    case show
    case hide
}

@MainActor
protocol ShowOrHideMakable: AnyObject {
    func changeConditionUsing(action: ShowAction)
}

class ShowOrHideControl: UIControl {

    lazy var showOrHideLabel: UILabel = {
        let showOrHideLabel = UILabel()
        showOrHideLabel.font = UIFont.systemFont(ofSize: 15)
        showOrHideLabel.text = "Показать"
        showOrHideLabel.textColor = Colors.colorBlue.value
        showOrHideLabel.textAlignment = .right
        return showOrHideLabel
    }()

    weak var delegate: ShowOrHideMakable?

    override init(frame: CGRect) {
        super.init(frame: frame)

        configureShowOrHideLabel()
        configureTapGR()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        configureShowOrHideLabel()
        configureTapGR()
    }

    private func configureShowOrHideLabel() {
        showOrHideLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(showOrHideLabel)

        NSLayoutConstraint.activate([
            showOrHideLabel.topAnchor.constraint(equalTo: self.topAnchor),
            showOrHideLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            showOrHideLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            showOrHideLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }

    private func configureTapGR() {
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(showOrHide))
        self.addGestureRecognizer(tapGR)
    }

    @objc private func showOrHide() {
        delegate?.changeConditionUsing(action: showOrHideLabel.text == "Показать" ? .hide : .show)
    }

}
