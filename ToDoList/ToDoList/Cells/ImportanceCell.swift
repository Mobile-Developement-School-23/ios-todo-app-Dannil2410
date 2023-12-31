//
//  ImportanceCell.swift
//  ToDoList
//
//  Created by Даниил Кизельштейн on 20.06.2023.
//

import UIKit

class ImportanceCell: UITableViewCell {

    //MARK: - Properties
    
    static let indentifier = "ImportanceCell"
    
    private lazy var importanceLabel: UILabel = {
        let importance = UILabel()
        importance.font = UIFont.systemFont(ofSize: 17)
        importance.text = "Важность"
        importance.translatesAutoresizingMaskIntoConstraints = false
        return importance
    }()
    
    private lazy var unimortantImageView: UIImageView = {
        let commonImageView = UIImageView()
        let imageConfiguration = UIImage.SymbolConfiguration(pointSize: 14, weight: .bold, scale: .large)
        commonImageView.image = UIImage(
            systemName: "arrow.down",
            withConfiguration: imageConfiguration)?.withTintColor(
                Colors.colorGray.value,
                renderingMode: .alwaysOriginal)
        return commonImageView
    }()
    
    private lazy var commonLabel: UILabel = {
       let unimportantLabel = UILabel()
        unimportantLabel.text = "нет"
        unimportantLabel.tintColor = Colors.labelPrimary.value
        unimportantLabel.font = UIFont.systemFont(ofSize: 15)
        unimportantLabel.textAlignment = .center
        return unimportantLabel
    }()
    
    private lazy var importantImageView: UIImageView = {
        let importantImageView = UIImageView()
        let imageConfiguration = UIImage.SymbolConfiguration(pointSize: 16, weight: .bold, scale: .large)
        importantImageView.image = UIImage(
            systemName: "exclamationmark.2",
            withConfiguration: imageConfiguration)?.withTintColor(
                Colors.colorRed.value,
                renderingMode: .alwaysOriginal)
        return importantImageView
    }()
    
    lazy var importanceSegmentedControl: UISegmentedControl = {
        guard let commonImage = unimortantImageView.image,
              let unimportantText = commonLabel.text,
              let importantImage = importantImageView.image else {
            return UISegmentedControl()
        }
        
        let importanceSegmentedControl = UISegmentedControl(items: [
            commonImage, unimportantText, importantImage
        ])
        
        importanceSegmentedControl.selectedSegmentIndex = 2
        
        importanceSegmentedControl.layer.masksToBounds = false
        importanceSegmentedControl.layer.cornerRadius = 8.91
        importanceSegmentedControl.backgroundColor = Colors.supportOverlay.value
        
        importanceSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        return importanceSegmentedControl
    }()

    //MARK: - Lifecircle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configureCell()
        configureImportanceLabel()
        configureImportanceSegmentedControl()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        configureCell()
        configureImportanceLabel()
        configureImportanceSegmentedControl()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setCorners()
    }
    
    //MARK: - Configure functions
    
    private func configureCell() {
        selectionStyle = .none
        
        backgroundColor = Colors.backSecondary.value
    }
    
    private func configureImportanceLabel() {
        contentView.addSubview(importanceLabel)
        
        NSLayoutConstraint.activate([
            importanceLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 17),
            importanceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            importanceLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -17)
        ])
    }
    
    private func configureImportanceSegmentedControl() {
        contentView.addSubview(importanceSegmentedControl)
        
        NSLayoutConstraint.activate([
            importanceSegmentedControl.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            importanceSegmentedControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            importanceSegmentedControl.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            importanceSegmentedControl.widthAnchor.constraint(equalToConstant: 150)
        ])
    }
    
    //MARK: fuctions for setting cornerRadius for cell
    
    private func setCorners() {
        let cornerRadius: CGFloat = 16
        
        roundCorners(corners: [.topLeft, .topRight], radius: cornerRadius)
    
    }
}
