//
//  HeaderForSectionView.swift
//  ToDoList
//
//  Created by Даниил Кизельштейн on 27.06.2023.
//

import UIKit

class HeaderForSectionView: UIView {
    
    static let countDoneItemsChanged = Notification.Name("count done items changed")
    
    private var text: String {
        "Выполнено - \(countDoneItems)"
    }
    
    private lazy var countDoneItemsLabel: UILabel = {
        let countDoneItemsLabel = UILabel()
        countDoneItemsLabel.font = UIFont.systemFont(ofSize: 15)
        countDoneItemsLabel.textColor = Colors.labelTeritary.value
        countDoneItemsLabel.text = text
        countDoneItemsLabel.numberOfLines = 1
        return countDoneItemsLabel
    }()
    
    lazy var showOrHideControl = ShowOrHideControl()
    
    var countDoneItems = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureCountDoneItems()
        configureShowOrHideControl()
        
        NotificationCenter.default.addObserver(self, selector: #selector(countItemsDoneChanged), name: HeaderForSectionView.countDoneItemsChanged, object: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        configureCountDoneItems()
        configureShowOrHideControl()
        
        NotificationCenter.default.addObserver(self, selector: #selector(countItemsDoneChanged), name: HeaderForSectionView.countDoneItemsChanged, object: nil)
    }
    
    @objc private func countItemsDoneChanged() {
        countDoneItems += 1
        countDoneItemsLabel.text = text
        setNeedsLayout()
    }
    
    private func configureCountDoneItems() {
        countDoneItemsLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(countDoneItemsLabel)
        
        NSLayoutConstraint.activate([
            countDoneItemsLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 18),
            countDoneItemsLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16)
        ])
    }
    
    private func configureShowOrHideControl() {
        showOrHideControl.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(showOrHideControl)
        
        let trailingAnchor = showOrHideControl.leadingAnchor.constraint(equalTo: countDoneItemsLabel.trailingAnchor, constant: 100)
        trailingAnchor.priority = .defaultHigh
        
        NSLayoutConstraint.activate([
            showOrHideControl.topAnchor.constraint(equalTo: self.topAnchor, constant: 18),
            showOrHideControl.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            showOrHideControl.heightAnchor.constraint(equalTo: countDoneItemsLabel.heightAnchor),
            trailingAnchor
        ])
    }
    
    func configureView(countDoneItems: Int) {
        self.countDoneItems = countDoneItems
        countDoneItemsLabel.text = text
    }
}
