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
        deleteLabel.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
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
        
        adjustMyFrame()
        setCorners()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - Configure functions
    
    private func configureCell() {
        selectionStyle = .none
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
        self.deleteLabel.textColor = hasText ? UIColor(red: 1, green: 0.231, blue: 0.188, alpha: 1) : UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
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
