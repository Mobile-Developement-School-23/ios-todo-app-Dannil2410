//
//  ItemListCell.swift
//  ToDoList
//
//  Created by Даниил Кизельштейн on 27.06.2023.
//

import UIKit

protocol ItemIsDoneChangable: AnyObject {
    func itemIsDoneChanged(item: ToDoItem)
}

class ItemListCell: UITableViewCell {

    // MARK: - Properties

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

    private lazy var briefTextLabelBottomAnchor = briefTextLabel
        .bottomAnchor
        .constraint(equalTo: contentView.bottomAnchor, constant: -17)

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

    private lazy var doneItemButton: UIButton = {
        let doneItemButton = UIButton()
        doneItemButton.setImage(UIImage(
            systemName: "circle")?
            .withTintColor(
                Colors.supportSeparator.value,
                renderingMode: .alwaysOriginal), for: .normal)
        doneItemButton.addTarget(self, action: #selector(doneItemChanged), for: .touchUpInside)
        return doneItemButton
    }()

    var item: ToDoItem?

    var hidesTopSeparator = false
    var hidesBottomSeparator = false

    weak var delegate: ItemIsDoneChangable?

    // MARK: - Lifecircle

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        configureDoneButtonImage()
        configureBriefTextDefault()
        configureBriefTextLabel()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        configureDoneButtonImage()
        configureBriefTextDefault()
        configureBriefTextLabel()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        setCorners()
        hideTopBottomSeparator()

        doneItemButton.layer.cornerRadius = 12
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

    // MARK: - Configure functions

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

        doneItemButton.isHidden = lastCell ? true : false

        accessoryType = hidesBottomSeparator ? .none : .disclosureIndicator
    }

    // MARK: - Functions about briefTextLabel

    private func configureBriefTextLabel() {
        briefTextLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(briefTextLabel)

        NSLayoutConstraint.activate([
            briefTextLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 17),
            briefTextLabel.leadingAnchor.constraint(equalTo: doneItemButton.trailingAnchor, constant: 12),
            briefTextLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            briefTextLabelBottomAnchor
        ])
    }

    func configureBriefTextDefault() {
        briefTextLabel.textColor = Colors.labelTeritary.value
        briefTextLabel.text = "Новое"
    }

    func configureBriefText(item: ToDoItem) {
        self.item = item

        if item.isDone {
            doneItemButton.setImage(configureDoneItemImage(), for: .normal)

            briefTextLabel.attributedText = configureImportanceImage(
                importance: item.importance,
                text: item.text,
                isDoneItem: true
            )
            briefTextLabel.textColor = Colors.labelTeritary.value
        } else {
            if item.importance == .important {
                doneItemButton.setImage(configureDoneItemImageForImportant(), for: .normal)
            } else {
                doneItemButton.setImage(configureDoneItemImageDefault(), for: .normal)
            }

            briefTextLabel.attributedText = configureImportanceImage(
                importance: item.importance,
                text: item.text,
                isDoneItem: false
            )

            briefTextLabel.textColor = Colors.labelPrimary.value
        }
    }

    private func configureImportanceImage(importance: Importance, text: String, isDoneItem: Bool) -> NSMutableAttributedString {
        let fullString: NSMutableAttributedString
        if importance == .common {
            fullString = NSMutableAttributedString(string: text)
        } else {
            let config = UIImage
                .SymbolConfiguration(
                    pointSize: importance == .important ? 16 : 14, weight: .bold, scale: .large
                )
            let imageAttachment = NSTextAttachment()
            imageAttachment.image = UIImage(
                systemName: importance == .important ? "exclamationmark.2" : "arrow.down",
                withConfiguration: config)?
                .withTintColor(
                    importance == .important ? Colors.colorRed.value : Colors.colorGray.value,
                    renderingMode: .alwaysOriginal)
            fullString = NSMutableAttributedString(string: "")
            fullString.append(NSAttributedString(attachment: imageAttachment))
            fullString.append(NSAttributedString(string: text))
        }
        if isDoneItem {
            fullString
                .addAttribute(
                    NSAttributedString.Key.strikethroughStyle,
                    value: 2,
                    range: NSRange(location: 0, length: fullString.length)
                )
        }
        return fullString
    }

    // MARK: - Functions about deadLineLabel

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
            let deadLineString = NSMutableAttributedString(string: "")
            deadLineString.append(NSAttributedString(attachment: deadLineAttachment))
            deadLineString.append(NSAttributedString(string: " " + dateFormatter.string(from: deadLine)))
            deadLineLabel.attributedText = deadLineString
        }
    }

    // MARK: - Fuctions about doneItemImageView

    private func configureDoneButtonImage() {
        doneItemButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(doneItemButton)

        NSLayoutConstraint.activate([
            doneItemButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            doneItemButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            doneItemButton.widthAnchor.constraint(equalToConstant: 24),
            doneItemButton.heightAnchor.constraint(equalTo: doneItemButton.widthAnchor)
        ])
    }

    @objc private func doneItemChanged() {
        guard let item = self.item else { return }

        UIView.transition(with: doneItemButton,
                          duration: 0.2,
                          options: .transitionFlipFromTop,
                          animations: { [weak self] in
            guard let self else { return }
            self.doneItemButton
                .setImage(
                    !item.isDone ? self.configureDoneItemImage()
                    : (item.importance == .important ? self.configureDoneItemImageForImportant()
                    : self.configureDoneItemImageDefault()), for: .normal)
        })

        delegate?.itemIsDoneChanged(item: item)
    }

    private func configureDoneItemImageDefault() -> UIImage? {
        return UIImage(
            systemName: "circle")?
            .withTintColor(
                Colors.supportSeparator.value,
                renderingMode: .alwaysOriginal)
    }

    private func configureDoneItemImage() -> UIImage? {
        return UIImage(
            systemName: "checkmark.circle.fill")?
            .withTintColor(
                Colors.colorGreen.value,
                renderingMode: .alwaysOriginal)
    }

    private func configureDoneItemImageForImportant() -> UIImage? {
        return UIImage(
            systemName: "circle")?
            .withTintColor(
                Colors.colorRed.value,
                renderingMode: .alwaysOriginal)
    }
}
