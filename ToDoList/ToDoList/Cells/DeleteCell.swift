//
//  DeleteCell.swift
//  ToDoList
//
//  Created by Даниил Кизельштейн on 21.06.2023.
//

import UIKit

class DeleteCell: UITableViewCell {

    //MARK: - Properties
    
    static let identifier = "DeleteCell"
    
    lazy var deleteLabel: UILabel = {
        let deleteLabel = UILabel()
        deleteLabel.textColor = Colors.labelTeritary.value
        deleteLabel.font = UIFont.systemFont(ofSize: 17)
        deleteLabel.text = "Удалить"
        deleteLabel.translatesAutoresizingMaskIntoConstraints = false
        return deleteLabel
    }()
    
    //MARK: - Lifecircle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configureCell()
        configureDeleteLabel()
        configureWorkWithNotificationCenter()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        configureCell()
        configureDeleteLabel()
        configureWorkWithNotificationCenter()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setCorners()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - Configure functions
    
    private func configureCell() {
        selectionStyle = .none
        
        backgroundColor = Colors.backSecondary.value
    }
    
    private func configureDeleteLabel() {
        contentView.addSubview(deleteLabel)
        
        NSLayoutConstraint.activate([
            deleteLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 17),
            deleteLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            deleteLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -17)
        ])
    }
    
    private func configureWorkWithNotificationCenter() {
        let notificationName = Notification.Name(TextCell.notificationHasText)
        NotificationCenter.default.addObserver(self, selector: #selector(toDoIfHasText(_:)), name: notificationName, object: nil)
    }
    
    //MARK: - Selector functions
    
    @objc private func toDoIfHasText(_ notification: Notification) {
        let hasText = notification.userInfo?["hasText"] as? Bool ?? false
        
        self.deleteLabel.textColor = hasText ? Colors.colorRed.value : Colors.labelTeritary.value
    }
    
    //MARK: fuctions for setting cornerRadius for cell
    
    private func setCorners() {
        let cornerRadius: CGFloat = 16
        
        roundCorners(corners: .allCorners, radius: cornerRadius)
    }
}
