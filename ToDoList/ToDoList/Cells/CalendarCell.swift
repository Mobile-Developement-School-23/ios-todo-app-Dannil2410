//
//  CalendarCell.swift
//  ToDoList
//
//  Created by Даниил Кизельштейн on 21.06.2023.
//

import UIKit

protocol DeadLineSettable: AnyObject {
    func setDeadLine(date: Date)
}

class CalendarCell: UITableViewCell {
    
    //MARK: - Properties

    static let identifier = "CalendarCell"
    
    static let notificationAddDeadline = "set deadLine"
    
    private lazy var calendarView: UICalendarView = {
        let calendarView = UICalendarView()
        let gregorianCalendar = Calendar(identifier: .gregorian)
        calendarView.calendar = gregorianCalendar
        
        calendarView.availableDateRange = DateInterval(start: Date.now, end: Date.distantFuture)
    
        let dataSelection = UICalendarSelectionSingleDate(delegate: self)
        calendarView.selectionBehavior = dataSelection
        
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        
        return calendarView
    }()
    
    weak var delegate: DeadLineSettable?
    
    //MARK: - Lifecircle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configureCell()
        configureCalendarView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        configureCell()
        configureCalendarView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        adjustMyFrame()
        setCorners()
    }
    
    //MARK: - Configure functions
    
    private func configureCell() {
        selectionStyle = .none
    }
    
    private func configureCalendarView() {
        contentView.addSubview(calendarView)
        
        NSLayoutConstraint.activate([
            calendarView.topAnchor.constraint(equalTo: contentView.topAnchor),
            calendarView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            calendarView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            calendarView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            calendarView.heightAnchor.constraint(equalToConstant: 332)
        ])
    }
    
    //MARK: fuctions for setting cornerRadius for cell
    
    private func adjustMyFrame() {
        frame = CGRect(x: 16, y: frame.minY, width: superview!.frame.width - 32, height: frame.height)
    }
    
    private func setCorners() {
        let cornerRadius: CGFloat = 16
        roundCorners(corners: [.bottomLeft, .bottomRight], radius: cornerRadius)
    }
}

extension CalendarCell: UICalendarSelectionSingleDateDelegate {
    
    func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
        guard let dateComponents = dateComponents,
              let date = calendarView.calendar.date(from: dateComponents) else {
            return
        }
        
        delegate?.setDeadLine(date: date)
    }
    
    func dateSelection(_ selection: UICalendarSelectionSingleDate, canSelectDate dateComponents: DateComponents?) -> Bool {
        return true
    }
}
