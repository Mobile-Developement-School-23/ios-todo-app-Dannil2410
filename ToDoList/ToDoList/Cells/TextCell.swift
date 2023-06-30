//
//  TextCell.swift
//  ToDoList
//
//  Created by Даниил Кизельштейн on 19.06.2023.
//

import UIKit

protocol TextCellHeightUpdatable: AnyObject {
    func updateTextCellHeight(to height: CGFloat)
}

class TextCell: UITableViewCell {

    // MARK: - Properties

    static let identifier = "TextCell"

    static let notificationHasText = "Whether textView has text or not"

    lazy var textView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.font = UIFont.systemFont(ofSize: 17)
        textView.textColor = Colors.labelTeritary.value

        textView.text = "Что надо сделать?"
        textView.delegate = self
        textView.isScrollEnabled = false
        textView.textContainerInset = UIEdgeInsets(top: 17, left: 16, bottom: 16, right: 16)
        textView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(textView)
        return textView
    }()

    lazy var textViewHeightConstraint = self.textView.heightAnchor.constraint(equalToConstant: 120)

    weak var delegate: TextCellHeightUpdatable?

    // MARK: - Lifeceircle

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        configureCell()
        configureTextView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        configureCell()
        configureTextView()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        setCorners()
    }

    // MARK: - Cobfigure functions

    private func configureCell() {
        selectionStyle = .none

        backgroundColor = Colors.backSecondary.value

    }

    private func configureTextView() {
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: contentView.topAnchor),
            textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            textViewHeightConstraint
        ])
    }

    // MARK: fuctions for setting cornerRadius for cell

    private func setCorners() {
        let cornerRadius: CGFloat = 16

        roundCorners(corners: .allCorners, radius: cornerRadius)
    }
}

extension TextCell: UITextViewDelegate {

    // MARK: - Change color for delete and save buttons

    func textViewDidChange(_ textView: UITextView) {

        let notificationName = Notification
            .Name(TextCell.notificationHasText)

        NotificationCenter
            .default
            .post(
                name: notificationName,
                object: nil,
                userInfo: ["hasText": textView.hasText ? true : false]
            )

        let size = CGSize(width: contentView.frame.width - 32, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        delegate?.updateTextCellHeight(to: estimatedSize.height > 120 ? estimatedSize.height : 120)
    }

    // MARK: - Make placeholder

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Что надо сделать?" {
            textView.text = nil
            textView.textColor = Colors.labelPrimary.value

        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if !textView.hasText {
            textView.textColor = Colors.labelTeritary.value
            
            textView.text = "Что надо сделать?"
        }
    }
}
