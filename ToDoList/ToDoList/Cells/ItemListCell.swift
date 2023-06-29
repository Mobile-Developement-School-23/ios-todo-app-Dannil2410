//
//  ItemListCell.swift
//  ToDoList
//
//  Created by Даниил Кизельштейн on 27.06.2023.
//

import UIKit

class ItemListCell: UITableViewCell {
    
    //MARK: - Properties
    
    static let identifier = "ItemListCell"
    
    private enum TypeCell {
        case first
        case common
        case last
    }
    
    private lazy var calendarImageView: UIImageView = {
        let calendarImageView = UIImageView()
        return calendarImageView
    }()
    
    private var rowInSection: Int = 0
    private var cellType: TypeCell = .common
    
    private lazy var briefTextLabelBottomAnchor = briefTextLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -17)
    
    private lazy var briefTextLabel: UILabel = {
        let briefTextLabel = UILabel()
        briefTextLabel.font = UIFont.systemFont(ofSize: 17)
        briefTextLabel.numberOfLines = 3
        return briefTextLabel
    }()
    
    private lazy var deadLineLabel: UILabel = {
        let deadLineLabel = UILabel()
        deadLineLabel.font = UIFont.systemFont(ofSize: 15)
        deadLineLabel.textColor = Colors.labelTeritary.value
        return deadLineLabel
    }()
    
    private lazy var doneItemImageView: UIImageView = {
        let doneItemImageView = UIImageView()
        return doneItemImageView
    }()
    
    //private let circleConfig = UIImage.SymbolConfiguration(pointSize: 15, weight: .medium, scale: .large)
    
    var hidesTopSeparator = false
    var hidesBottomSeparator = false
    
    //MARK: - Lifecircle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configureDoneItemImageView()
        configureBriefTextDefault()
        configureBriefTextLabel()
        configureDoneItemImageDefault()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        configureDoneItemImageView()
        configureBriefTextDefault()
        configureBriefTextLabel()
        configureDoneItemImageDefault()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setCorners()
        hideTopBottomSeparator()
        
        doneItemImageView.layer.cornerRadius = 15
    }
    
    private func setCorners() {
        let cornerRadius: CGFloat = 16
        
        noCornerMask()
        
        if rowInSection == 1 {
            roundCorners(corners: .allCorners, radius: cornerRadius)
        } else {
            switch cellType {
            case .first:
                roundCorners(corners: [.topLeft, .topRight], radius: cornerRadius)
            case .last:
                roundCorners(corners: [.bottomLeft, .bottomRight], radius: cornerRadius)
            default:
                break
            }
        }
    }
    
    private func hideTopBottomSeparator() {
        let topSeparator = subviews.first { $0.frame.minY == 0 && $0.frame.height <= 1 }
        let bottomSeparator = subviews.first { $0.frame.minY >= bounds.maxY - 1 && $0.frame.height <= 1 }
        
        topSeparator?.isHidden = hidesTopSeparator
        bottomSeparator?.isHidden = hidesBottomSeparator
    }
    
    //MARK: - Configure functions
    
    func configureCell(rowInSection: Int, currentRow: Int, hasDeadLine: Bool, lastCell: Bool) {
        self.rowInSection = rowInSection
        self.cellType = currentRow == 0 ? .first : currentRow + 1 == rowInSection ? .last : .common
        selectionStyle = .none
        
        backgroundColor = Colors.backSecondary.value
        
        if hasDeadLine {
            configureDeadLineLabel()
        } else if contentView.subviews.contains(deadLineLabel) {
            briefTextLabelBottomAnchor.isActive = true
            deadLineLabel.removeFromSuperview()
        }
        
        doneItemImageView.isHidden = lastCell ? true : false
        
        accessoryType = hidesBottomSeparator ? .none : .disclosureIndicator
    }

    //MARK: - Functions about briefTextLabel
    
    private func configureBriefTextLabel() {
        briefTextLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(briefTextLabel)
        
        NSLayoutConstraint.activate([
            briefTextLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 17),
            briefTextLabel.leadingAnchor.constraint(equalTo: doneItemImageView.trailingAnchor, constant: 12),
            briefTextLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            briefTextLabelBottomAnchor
        ])
    }
    
    func configureBriefTextDefault() {
        briefTextLabel.textColor = Colors.labelTeritary.value
        briefTextLabel.text = "Новое"
    }
    
    func configureBriefText(item: ToDoItem) {
        if item.isDone {
            configureDoneItemImage()
            
            briefTextLabel.attributedText = configureImportanceImage(importance: item.importance, text: item.text, isDoneItem: true)
            briefTextLabel.textColor = Colors.labelTeritary.value
        } else {
            if item.importance == .important {
                configureDoneItemImageForImportant()
            } else {
                configureDoneItemImageDefault()
            }
            
            briefTextLabel.attributedText = configureImportanceImage(importance: item.importance, text: item.text, isDoneItem: false)
            
            briefTextLabel.textColor = Colors.labelPrimary.value
        }
    }
    
    private func configureImportanceImage(importance: Importance, text: String, isDoneItem: Bool) -> NSMutableAttributedString {
        if importance == .common {
            return NSMutableAttributedString(string: text)
        } else {
            let config = UIImage.SymbolConfiguration(pointSize: importance == .important ? 16 : 14, weight: .bold, scale: .large)
            let imageAttachment = NSTextAttachment()
            imageAttachment.image = UIImage(
                systemName: importance == .important ? "exclamationmark.2" : "arrow.down",
                withConfiguration: config)?
                .withTintColor(
                    importance == .important ? Colors.colorRed.value : Colors.colorGray.value,
                    renderingMode: .alwaysOriginal)
            let fullString = NSMutableAttributedString(string:  "")
            fullString.append(NSAttributedString(attachment: imageAttachment))
            fullString.append(NSAttributedString(string: text))
            if isDoneItem {
                fullString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSRange(location: 0, length: fullString.length))
            }
            return fullString
        }
    }
    
    //MARK: - Functions about deadLineLabel
    
    private func configureDeadLineLabel() {
        deadLineLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(deadLineLabel)
        
        briefTextLabelBottomAnchor.isActive = false
        
        NSLayoutConstraint.activate([
            deadLineLabel.topAnchor.constraint(equalTo: briefTextLabel.bottomAnchor),
            deadLineLabel.leadingAnchor.constraint(equalTo: briefTextLabel.leadingAnchor),
            deadLineLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
        layoutIfNeeded()
    }
    
    func configureDeadLineText(deadLine: Date?, dateFormatter: DateFormatter) {
        if let deadLine = deadLine {
            let config = UIImage.SymbolConfiguration(font: .systemFont(ofSize: 15), scale: .default)
            let deadLineAttachment = NSTextAttachment()
            deadLineAttachment.image = UIImage(
                systemName: "calendar",
                withConfiguration: config)?
                .withTintColor(
                    Colors.labelTeritary.value,
                    renderingMode: .alwaysOriginal)
            let deadLineString = NSMutableAttributedString(string:  "")
            deadLineString.append(NSAttributedString(attachment: deadLineAttachment))
            deadLineString.append(NSAttributedString(string: " " + dateFormatter.string(from: deadLine)))
            deadLineLabel.attributedText = deadLineString
        }
    }
    
    //MARK: - Fuctions about doneItemImageView
    
    private func configureDoneItemImageView() {
        doneItemImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(doneItemImageView)
        
        NSLayoutConstraint.activate([
            doneItemImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            doneItemImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            doneItemImageView.widthAnchor.constraint(equalToConstant: 24),
            doneItemImageView.heightAnchor.constraint(equalTo: doneItemImageView.widthAnchor)
        ])
    }
    
    private func configureDoneItemImageDefault() {
        doneItemImageView.image = UIImage(
            systemName: "circle")?
            .withTintColor(
                Colors.supportSeparator.value,
                renderingMode: .alwaysOriginal)
    }
    
    private func configureDoneItemImage() {
        doneItemImageView.image = UIImage(
            systemName: "checkmark.circle.fill")?
            .withTintColor(
                Colors.colorGreen.value,
                renderingMode: .alwaysOriginal)
    }
    
    private func configureDoneItemImageForImportant() {
        doneItemImageView.image = UIImage(
            systemName: "circle")?
            .withTintColor(
                Colors.colorRed.value,
                renderingMode: .alwaysOriginal)
        //doneItemImageView.backgroundColor = .black
        //doneItemImageView.image = UIImage(named: "importanceLight")
    }
}
