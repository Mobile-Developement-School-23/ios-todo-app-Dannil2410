//
//  ViewController.swift
//  ToDoList
//
//  Created by Даниил Кизельштейн on 12.06.2023.
//

import UIKit

class ItemViewController: UIViewController {
    
    //MARK: - Properties
    
    private lazy var tableView = UITableView()
    
    private let indexPathTextCell = IndexPath(row: 0, section: 0)
    private let indexPathImportanceCell = IndexPath(row: 0, section: 1)
    private let indexPathSetDeadLineCell = IndexPath(row: 1, section: 1)
    private let indexPathCalendarCell = IndexPath(row: 2, section: 1)
    private let indexPathDeleteCell = IndexPath(row: 0, section: 2)
    
    private lazy var fileCache: FileCache = {
        let fileCache = FileCache()
        do {
            try fileCache.loadItemsFromFileSystem(fileName: "test", type: .json)
        } catch let error {
            print(error)
        }
        return fileCache
    }()
    private var toDoItem: ToDoItem?
    //private var tapGR: UITapGestureRecognizer?
    
    private var countRowsInSecondSection = 2
    
    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM y"
        return dateFormatter
    }()
    
    //MARK: - Lifecircle
    
    override func loadView() {
        super.loadView()
        
        self.view.layer.backgroundColor = UIColor(red: 0.97, green: 0.966, blue: 0.951, alpha: 1).cgColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Дело"
        
        configureTableView()
        registrationTableViewCells()
        configureNavigationItems()
        configureWorkWithNotificationCenter()
        
        toDoItem = fileCache.items.first
        
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        //tapGR.numberOfTapsRequired = 2
        tapGR.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGR)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - Cobfigure functions
    
    private func configureTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.backgroundColor = UIColor(red: 0.97, green: 0.966, blue: 0.951, alpha: 1)
        tableView.sectionHeaderTopPadding = 0
    }
    
    private func registrationTableViewCells() {
        tableView.register(TextCell.self, forCellReuseIdentifier: TextCell.identifier)
        tableView.register(ImportanceCell.self, forCellReuseIdentifier: ImportanceCell.indentifier)
        tableView.register(SetDeadLineCell.self, forCellReuseIdentifier: SetDeadLineCell.identifier)
        tableView.register(CalendarCell.self, forCellReuseIdentifier: CalendarCell.identifier)
        tableView.register(DeleteCell.self, forCellReuseIdentifier: DeleteCell.identifier)
    }
    
    private func configureNavigationItems() {
        let leftBarButtonItem = UIBarButtonItem(title: "Отменить", style: .plain, target: nil, action: #selector(leftBarButtonItemToDo))
        leftBarButtonItem.tintColor = UIColor(red: 0, green: 0.478, blue: 1, alpha: 1)
        
        let rightBarButtonItem = UIBarButtonItem(title: "Сохранить", style: .plain, target: nil, action: #selector(rightBarButtonItemToDo))
        rightBarButtonItem.tintColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        rightBarButtonItem.isEnabled = false

        self.navigationItem.leftBarButtonItem = leftBarButtonItem
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    private func configureWorkWithNotificationCenter() {
        let notificationHasText = Notification.Name(TextCell.notificationHasText)
        NotificationCenter.default.addObserver(self, selector: #selector(toDoIfHasText(_:)), name: notificationHasText, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(willShowKeyboard(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(willHideKeyboard(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    //MARK: - Selector functions
    
    @objc private func rightBarButtonItemToDo() {
        gatherToDoItem()
        if let toDoItem = toDoItem {
            fileCache.appendItem(toDoItem)
        }
        do {
            try fileCache.saveItemsToFileSystem(fileName: "test", type: .json)
        } catch let error {
            print(error)
        }
    }
    
    private func gatherToDoItem() {
        guard let textCell = tableView.cellForRow(at: indexPathTextCell) as? TextCell,
              let importanceCell = tableView.cellForRow(at: indexPathImportanceCell) as? ImportanceCell,
              let setDeadLineCell = tableView.cellForRow(at: indexPathSetDeadLineCell) as? SetDeadLineCell else {
            return
        }
        
        var id: String?
        var startTime: Double?
        var changeTime: Double?
        var deadLine: Double?
        if let toDoItem = toDoItem {
            id = toDoItem.id
            startTime = toDoItem.startTime.timeIntervalSince1970
        }
        let text = textCell.textView.text
        let importance = Importance.allCases[importanceCell.importanceSegmentedControl.selectedSegmentIndex]
        let isDone = false
        
        if startTime != nil {
            changeTime = Date.now.timeIntervalSince1970
        }

        if let deadLineString = setDeadLineCell.deadLineLabel.text {
            deadLine = dateFormatter.date(from: deadLineString)?.timeIntervalSince1970
        }
        self.toDoItem = ToDoItem(
            id: id ?? UUID().uuidString,
            text: text ?? "",
            importance: importance,
            deadLineTimeIntervalSince1970: deadLine,
            isDone: isDone,
            startTimeIntervalSince1970: startTime ?? Date.now.timeIntervalSince1970,
            changeTimeIntervalSince1970: changeTime
        )
    }
    
    @objc private func leftBarButtonItemToDo() {
        
        print("Отменить")
    }
    
    @objc private func toDoIfHasText(_ notification: Notification) {
        let hasText = notification.userInfo?["hasText"] as? Bool ?? false
        if hasText {
            navigationItem.rightBarButtonItem?.tintColor = UIColor(red: 0, green: 0.478, blue: 1, alpha: 1)
            navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            navigationItem.rightBarButtonItem?.tintColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.3)
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
    @objc func dismissKeyboard() {
        let cell = tableView.cellForRow(at: indexPathTextCell) as! TextCell
        cell.textView.resignFirstResponder()
        view.endEditing(true)
    }
    
    @objc func willShowKeyboard(_ notification: Notification) {
        guard let info = notification.userInfo as NSDictionary?,
              let keyboardSize = info.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as? NSValue else {return}
        
        let keyboardHight = keyboardSize.cgRectValue.size.height
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHight, right: 0)
    }
    
    @objc func willHideKeyboard(_ notification: Notification) {
        tableView.contentInset = UIEdgeInsets.zero
    }
}

extension ItemViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 || section == 2 ? 1 : countRowsInSecondSection
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            //TextCell
            guard let cell = tableView.dequeueReusableCell(withIdentifier: TextCell.identifier, for: indexPath) as? TextCell else {
                preconditionFailure("TextCell can not be dequeued")
            }
            if let toDoItem = toDoItem {
                cell.textView.text = toDoItem.text
                cell.textView.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
                NotificationCenter
                    .default
                    .post(
                        name: NSNotification.Name(rawValue: TextCell.notificationHasText),
                        object: nil,
                        userInfo: ["hasText": true]
                    )
            }
            return cell

        } else if indexPath.section == 1 {
            //ImportanceCell
            if indexPath.row == 0 {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: ImportanceCell.indentifier, for: indexPath) as? ImportanceCell else {
                    preconditionFailure("ImportanceCell can not be dequeued")
                }
                if let toDoItem = toDoItem {
                    cell.importanceSegmentedControl.selectedSegmentIndex = Importance.allCases.firstIndex(of: toDoItem.importance) ?? 2
                }
                return cell
                
            } else if indexPath.row == 1 {
                //SetDeadLineCell
                guard let cell = tableView.dequeueReusableCell(withIdentifier: SetDeadLineCell.identifier, for: indexPath) as? SetDeadLineCell else {
                    preconditionFailure("SetDeadLineCell can not be dequeued")
                }
                if let toDoItem = toDoItem,
                   let deadLine = toDoItem.deadLine {
                    cell.deadLineLabel.text = dateFormatter.string(from: deadLine)
                    cell.switcher.isOn = true
                    cell.toDoIfSenderIsOn()
                }
                
                cell
                    .configureCell(
                        dateFormatter: dateFormatter,
                        selectedDay: nil
                    )
                cell.delegate = self
                return cell
                
            } else if countRowsInSecondSection == 3 {
                //CalendarCell
                guard let cell = tableView.dequeueReusableCell(withIdentifier: CalendarCell.identifier, for: indexPath) as? CalendarCell else {
                    preconditionFailure("CalendarCell can not be dequeued")
                }
                cell.delegate = self
                return cell
                
            }
        } else {
            //DeleteCell
            guard let cell = tableView.dequeueReusableCell(withIdentifier: DeleteCell.identifier, for: indexPath) as? DeleteCell else {
                preconditionFailure("DeleteCell can not be dequeued")
            }
            if toDoItem != nil {
                cell.deleteLabel.textColor = UIColor(red: 1, green: 0.231, blue: 0.188, alpha: 1)
            }
            return cell
            
        }
        return UITableViewCell()
    }
}


extension ItemViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        16
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        section == 2 ? 1 : 0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        UIView()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath == indexPathSetDeadLineCell,
           let cell = tableView.cellForRow(at: indexPathSetDeadLineCell) as? SetDeadLineCell,
           cell.switcher.isOn == true {
            if self.countRowsInSecondSection == 2 {
                tableView.beginUpdates()
                self.tableView.insertRows(at: [indexPathCalendarCell], with: .fade)
                self.countRowsInSecondSection += 1
                cell.calendarIsActive = true
                tableView.endUpdates()
            } else {
                tableView.beginUpdates()
                self.tableView.deleteRows(at: [indexPathCalendarCell], with: .fade)
                self.countRowsInSecondSection -= 1
                cell.calendarIsActive = false
                tableView.endUpdates()
            }
        } else if indexPath == indexPathDeleteCell,
                  let cell = tableView.cellForRow(at: indexPathDeleteCell) as? DeleteCell,
                  cell.deleteLabel.textColor == UIColor(red: 1, green: 0.231, blue: 0.188, alpha: 1),
                  let toDoItem = self.toDoItem {
            fileCache.deleteItem(for: toDoItem.id)
            do {
                try fileCache.saveItemsToFileSystem(fileName: "test", type: .json)
            } catch let error {
                print(error)
            }
        }
        
    }
}

extension ItemViewController: SwitchCalendarHidable {
    func hideCalendar() {
        if countRowsInSecondSection == 3,
           let cell = tableView.cellForRow(at: indexPathSetDeadLineCell) as? SetDeadLineCell {
            cell.calendarIsActive = false
            tableView.beginUpdates()
            self.tableView.deleteRows(at: [indexPathCalendarCell], with: .fade)
            self.countRowsInSecondSection = 2
            tableView.endUpdates()
        }
    }
}

extension ItemViewController: DeadLineSettable {
    func setDeadLine(date: Date) {
        guard let cell = tableView.cellForRow(at: indexPathSetDeadLineCell) as? SetDeadLineCell else {
            return
        }
        cell.deadLineLabel.text = dateFormatter.string(from: date.addingTimeInterval(3*60*60))
    }
}