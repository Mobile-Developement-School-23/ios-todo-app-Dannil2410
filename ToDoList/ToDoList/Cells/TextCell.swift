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

    //MARK: - Properties
    
    static let identifier = "TextCell"
    
    static let notificationHasText = "Whether textView has text or not"
    
    lazy var textView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.font = UIFont.systemFont(ofSize: 17)
        textView.textColor = UIColor(dynamicProvider: {
            traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(red: 1, green: 1, blue: 1, alpha: 0.4)
            default:
                return UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
            }
        })
        
        textView.text = "Что надо сделать?"
        textView.delegate = self
        textView.isScrollEnabled = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(textView)
        return textView
    }()
    
    lazy var textViewHeightConstraint = self.textView.heightAnchor.constraint(equalToConstant: 120)
    
    weak var delegate: TextCellHeightUpdatable?
    
    //MARK: - Lifeceircle
    
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
        
        adjustMyFrame()
        setCorners()
    }
    
    //MARK: - Cobfigure functions
    
    private func configureCell() {
        selectionStyle = .none
        
        backgroundColor = UIColor(dynamicProvider: {
            traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(red: 0.145, green: 0.145, blue: 0.155, alpha: 1)
            default:
                return UIColor(red: 1, green: 1, blue: 1, alpha: 1)
            }
        })

    }
    
    private func configureTextView() {
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 17),
            textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            textViewHeightConstraint
        ])
    }
    
    //MARK: fuctions for setting cornerRadius for cell
    
    private func adjustMyFrame() {
        guard let view = superview else { return }
        frame = CGRect(x: 16, y: frame.minY, width: view.frame.width - 32, height: frame.height)
    }

    private func setCorners() {
        let cornerRadius: CGFloat = 16

        roundCorners(corners: .allCorners, radius: cornerRadius)
    }
}

extension TextCell: UITextViewDelegate {
    
    //MARK: - Change color for delete and save buttons
    
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
    
    //MARK: - Make placeholder
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Что надо сделать?" {
            textView.text = nil
            textView.textColor = UIColor(dynamicProvider: {
                traitCollection in
                switch traitCollection.userInterfaceStyle {
                case .dark:
                    return UIColor(red: 1, green: 1, blue: 1, alpha: 1)
                default:
                    return UIColor(red: 0, green: 0, blue: 0, alpha: 1)
                }
            })
            
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if !textView.hasText {
            textView.textColor = UIColor(dynamicProvider: {
                traitCollection in
                switch traitCollection.userInterfaceStyle {
                case .dark:
                    return UIColor(red: 1, green: 1, blue: 1, alpha: 0.4)
                default:
                    return UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
                }
            })
            
            textView.text = "Что надо сделать?"
        }
    }
}
