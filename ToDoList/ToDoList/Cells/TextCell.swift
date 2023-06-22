//
//  TextCell.swift
//  ToDoList
//
//  Created by Даниил Кизельштейн on 19.06.2023.
//

import UIKit

class TextCell: UITableViewCell {

    //MARK: - Properties
    
    static let identifier = "TextCell"
    
    static let notificationHasText = "Whether textView has text or not"
    
    lazy var textView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 17)
        textView.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        textView.text = "Что надо сделать?"
        textView.delegate = self
        textView.isScrollEnabled = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(textView)
        return textView
    }()
    
    private var textViewHeightConstraint: NSLayoutConstraint {
        //let heightConstraint = self.textView.heightAnchor.constraint(greaterThanOrEqualToConstant: 120)
        //return heightConstraint
        return self.textView.heightAnchor.constraint(equalToConstant: 120)
        //return self.textView.heightAnchor.constraint(greaterThanOrEqualToConstant: textView.intrinsicContentSize.height < 120 ? 120 : textView.intrinsicContentSize.height)
    }
//    
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
    
    private func configureTextView() {
        //contentView.addSubview(textView)
        print(textViewHeightConstraint)
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 17),
            textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            //textView.heightAnchor.constraint(equalToConstant: textView.intrinsicContentSize.height)
            textViewHeightConstraint
        ])
    }
    
    private func configureCell() {
        selectionStyle = .none
    }
    
    //MARK: fuctions for setting cornerRadius for cell
    
    private func adjustMyFrame() {
        frame = CGRect(x: 16, y: frame.minY, width: superview!.frame.width - 32, height: frame.height)
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
    }
    
    //MARK: - Make placeholder
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor(red: 0, green: 0, blue: 0, alpha: 0.3) {
            textView.text = nil
            textView.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if !textView.hasText {
            textView.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
            textView.text = "Что надо сделать?"
        }
    }
}
