//
//  SetDeadLineCell.swift
//  ToDoList
//
//  Created by Даниил Кизельштейн on 20.06.2023.
//

import UIKit

protocol SwitchCalendarHidable: AnyObject {
    func hideCalendar()
}

class SetDeadLineCell: UITableViewCell {

    //MARK: - Properties
    
    static let identifier = "SetDeadLineCell"
    static let notificationHideCalendar = "Hide Calendar"
    
    private let doneByLabelHeightAnchorConstant: CGFloat = 17
    private var dateFormatter: DateFormatter?
    private var selectedDay: Date?
    var calendarIsActive: Bool = false
    
    weak var delegate: SwitchCalendarHidable?
    
    lazy var doneByLabel: UILabel = {
        let doneByLabel = UILabel()
        doneByLabel.font = UIFont.systemFont(ofSize: 17)
        doneByLabel.text = "Сделать до"
        doneByLabel.translatesAutoresizingMaskIntoConstraints = false
        return doneByLabel
    }()
    
    lazy var switcher: UISwitch = {
        let switcher = UISwitch()
        switcher.isSelected = false
        switcher.translatesAutoresizingMaskIntoConstraints = false
        switcher.addTarget(self, action: #selector(switchValueDidChange(_:)), for: .valueChanged)
        return switcher
    }()
    
    lazy var deadLineLabel: UILabel = {
       let deadLineLabel = UILabel()
        deadLineLabel.textColor = UIColor(red: 0, green: 0.478, blue: 1, alpha: 1)
        deadLineLabel.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        deadLineLabel.translatesAutoresizingMaskIntoConstraints = false
        return deadLineLabel
    }()
    
    //MARK: - Constraint properties
    
    private lazy var doneByLabelHeightAnchor: NSLayoutConstraint = {
        let doneByLabelHeightAnchor = self.doneByLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: doneByLabelHeightAnchorConstant)
        return doneByLabelHeightAnchor
    }()
    
    private lazy var doneByLabelBottomAnchor: NSLayoutConstraint = {
        let doneByLabelBottomAnchor = self.doneByLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -17)
        return doneByLabelBottomAnchor
    }()
    
    //MARK: - Lifecircle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configureDoneByLabel()
        configureSwitcher()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        configureDoneByLabel()
        configureSwitcher()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        adjustMyFrame()
        setCorners()
    }
    
    //MARK: - Configure functions
    
    func configureCell(dateFormatter: DateFormatter, selectedDay: Date?) {
        selectionStyle = .none
        self.dateFormatter = dateFormatter
        self.selectedDay = selectedDay
    }
    
    private func configureDoneByLabel() {
        contentView.addSubview(doneByLabel)
        
        NSLayoutConstraint.activate([
            doneByLabelHeightAnchor,
            doneByLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            doneByLabelBottomAnchor
        ])
    }
    
    private func configureSwitcher() {
        contentView.addSubview(switcher)
        
        NSLayoutConstraint.activate([
            switcher.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 13.5),
            switcher.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            switcher.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -13.5)
        ])
    }
    
    private func configureDeadLineLabel() {
        contentView.addSubview(deadLineLabel)
        
        NSLayoutConstraint.activate([
            deadLineLabel.topAnchor.constraint(equalTo: doneByLabel.bottomAnchor),
            deadLineLabel.leadingAnchor.constraint(equalTo: doneByLabel.leadingAnchor),
            deadLineLabel.trailingAnchor.constraint(equalTo: doneByLabel.trailingAnchor),
            deadLineLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -9)
        ])
    }
    
    //MARK: - Selector functions
    
    @objc private func switchValueDidChange(_ sender: UISwitch) {
        if sender.isOn {
            toDoIfSenderIsOn()
        } else {
            toDoIfSenderIsOff()
        }
    }
    
    func toDoIfSenderIsOn() {
        doneByLabelHeightAnchor.constant = 8
        doneByLabelBottomAnchor.isActive = false

        getNextDay()
        
        configureDeadLineLabel()
    }
    
    private func toDoIfSenderIsOff() {
        doneByLabelHeightAnchor.constant = doneByLabelHeightAnchorConstant
        doneByLabelBottomAnchor.isActive = true
        deadLineLabel.removeFromSuperview()
        
        delegate?.hideCalendar()
    }
    
    private func getNextDay() {
        let calendar: Calendar = Calendar.current
        var dayFutureComponents: DateComponents = DateComponents()
        dayFutureComponents.day = 1
        let today = Date.now
        if let nextDay = calendar.date(byAdding: dayFutureComponents, to: today),
           let dateFormatter = self.dateFormatter {
            deadLineLabel.text = dateFormatter.string(from: nextDay)
        }
    }
    
    //MARK: fuctions for setting cornerRadius for cell
    
    private func adjustMyFrame() {
        guard let view = superview else { return }
        frame = CGRect(x: 16, y: frame.minY, width: view.frame.width - 32, height: frame.height)
    }
    
    private func setCorners() {
        if calendarIsActive == false {
            let cornerRadius: CGFloat = 16
            roundCorners(corners: [.bottomLeft, .bottomRight], radius: cornerRadius)
        } else {
            noCornerMask()
        }
    }
}
