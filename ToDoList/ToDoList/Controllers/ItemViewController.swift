//
//  ViewController.swift
//  ToDoList
//
//  Created by Даниил Кизельштейн on 12.06.2023.
//

import UIKit

enum RequestMethod {
    case post, put, delete
}

@MainActor
protocol TableViewRowAppendable: AnyObject {
    func updateTableView(showOrHideAncestor: ShowAction, method: RequestMethod, item: ToDoItem)
}

class ItemViewController: UIViewController {

    // MARK: - Properties

    var toDoItem: ToDoItem?

    var showOrHideAncestor: ShowAction = .hide

    weak var delegate: TableViewRowAppendable?

    var isPortrait = true

    private lazy var tableView = UITableView()

    private let indexPathTextCell = IndexPath(row: 0, section: 0)
    private let indexPathImportanceCell = IndexPath(row: 0, section: 1)
    private let indexPathSetDeadLineCell = IndexPath(row: 1, section: 1)
    private let indexPathCalendarCell = IndexPath(row: 2, section: 1)
    private let indexPathDeleteCell = IndexPath(row: 0, section: 2)

    private var countRowsInSecondSection = 2

    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM y"
        dateFormatter.locale = Locale(identifier: "ru_RU")
        return dateFormatter
    }()

    private var attempToRecoverItem = false

    private let numberOfSection = 3

    private var currentImportance: Importance = .important

    private var currentDeadLine: Double?

    private var isNew = false

    // MARK: - Lifecircle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.layer.backgroundColor = Colors.backPrimary.value.cgColor

        self.title = "Дело"

        configureTableView()
        registrationTableViewCells()
        configureNavigationItems()
        configureWorkWithNotificationCenter()

        isNew = toDoItem == nil ? true : false

        let tapGR = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        tapGR.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGR)

        print(#function)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.view.layer.backgroundColor = Colors.backPrimary.value.cgColor
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Cobfigure functions

    private func configureTableView() {
        tableView.backgroundColor = .clear

        tableView.separatorColor = Colors.supportSeparator.value

        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])

        tableView.dataSource = self
        tableView.delegate = self

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
        let leftBarButtonItem = UIBarButtonItem(
            title: "Отменить",
            style: .plain,
            target: self,
            action: #selector(leftBarButtonItemToDo)
        )
        leftBarButtonItem.tintColor = Colors.colorBlue.value

        let rightBarButtonItem = UIBarButtonItem(
            title: "Сохранить",
            style: .done,
            target: self,
            action: #selector(rightBarButtonItemToDo)
        )
        rightBarButtonItem.tintColor = Colors.labelTeritary.value
        rightBarButtonItem.isEnabled = false

        self.navigationItem.leftBarButtonItem = leftBarButtonItem
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
    }

    private func configureWorkWithNotificationCenter() {
        let notificationHasText = Notification.Name(TextCell.notificationHasText)

        NotificationCenter
            .default
            .addObserver(
                self,
                selector: #selector(toDoIfHasText(_:)),
                name: notificationHasText,
                object: nil
            )

        NotificationCenter
            .default
            .addObserver(
                self,
                selector: #selector(willShowKeyboard(_:)),
                name: UIResponder.keyboardWillShowNotification,
                object: nil
            )

        NotificationCenter
            .default
            .addObserver(
                self,
                selector: #selector(willHideKeyboard(_:)),
                name: UIResponder.keyboardWillHideNotification,
                object: nil
            )

        NotificationCenter
            .default
            .addObserver(
                self,
                selector: #selector(rotated),
                name: UIDevice.orientationDidChangeNotification,
                object: nil
            )
    }

    // MARK: - Selector functions

    @objc private func rightBarButtonItemToDo() {
        if isPortrait {
            toDoIfIsPortrait()
        } else {
            toDoIfLandscape()
        }
    }

    private func toDoIfIsPortrait() {
        gatherToDoItem()
        if let item = toDoItem,
           !attempToRecoverItem {
            delegate?.updateTableView(showOrHideAncestor: showOrHideAncestor, method: isNew ? .post : .put, item: item)
            self.dismiss(animated: true)
        }
    }

    private func toDoIfLandscape() {
        guard let textCell = tableView.cellForRow(at: indexPathTextCell) as? TextCell else {
            return
        }
        if let toDoItem = toDoItem {
            // если ничего не изменилось в isDone = true
            if toDoItem.isDone,
               toDoItem.text == textCell.textView.text,
               toDoItem.importance == currentImportance,
               currentDeadLine == nil {
                self.dismiss(animated: true)
            }
            // если что-то поменялось в isDone = true
            else if toDoItem.isDone {
                self.toDoItem = ToDoItem(
                    id: toDoItem.id,
                    text: textCell.textView.text,
                    importance: currentImportance,
                    deadLineTimeIntervalSince1970: currentDeadLine,
                    isDone: false,
                    startTimeIntervalSince1970: Date.now.timeIntervalSince1970,
                    changeTimeIntervalSince1970: nil)
                createAlertController(toDoItem: toDoItem)
            } else {
                // если были какие-то изменения, то сохранить с ними
                toDoIfNotDoneChangedLandscape(textCell: textCell)
            }
        } else {
            toDoIfNotDoneChangedLandscape(textCell: textCell)
        }
    }

    private func toDoIfNotDoneChangedLandscape(textCell: TextCell) {
        let startTime = toDoItem?.startTime.timeIntervalSince1970
        let item = ToDoItem(
            id: toDoItem?.id ?? UUID().uuidString,
            text: textCell.textView.text,
            importance: currentImportance,
            deadLineTimeIntervalSince1970: currentDeadLine,
            isDone: false,
            startTimeIntervalSince1970: startTime ?? Date.now.timeIntervalSince1970,
            changeTimeIntervalSince1970: startTime == nil ? nil : Date.now.timeIntervalSince1970
        )
        delegate?.updateTableView(showOrHideAncestor: showOrHideAncestor, method: isNew ? .post : .put, item: item)
        self.dismiss(animated: true)
    }

    private func gatherToDoItem() {
        guard let textCell = tableView.cellForRow(at: indexPathTextCell) as? TextCell,
              let importanceCell = tableView.cellForRow(at: indexPathImportanceCell) as? ImportanceCell,
              let setDeadLineCell = tableView.cellForRow(at: indexPathSetDeadLineCell) as? SetDeadLineCell else {
            return
        }

        var startTime: Double?
        var deadLine: Double?

        let text = textCell.textView.text
        let importance = Importance
            .allCases[
                importanceCell
                    .importanceSegmentedControl
                    .selectedSegmentIndex
            ]

        if let deadLineString = setDeadLineCell.deadLineLabel.text {
            deadLine = dateFormatter.date(from: deadLineString)?.timeIntervalSince1970
        }

        if let toDoItem = toDoItem {
            // если поля не поменялись, то ничего не делаем
            if toDoItem.isDone,
               toDoItem.text == text,
               toDoItem.importance == importance,
               deadLine == nil {
                return
            } else if toDoItem.isDone {
                // поля поменялись, поэтому создаем alert для подтверждения изменений
                createAlertController(toDoItem: toDoItem)
               }
            // если поля поменялись или задача была не isDone
            startTime = toDoItem.isDone ? nil : toDoItem.startTime.timeIntervalSince1970
        }

        self.toDoItem = ToDoItem(
            id: toDoItem?.id ?? UUID().uuidString,
            text: text ?? "",
            importance: importance,
            deadLineTimeIntervalSince1970: deadLine,
            isDone: false,
            startTimeIntervalSince1970: startTime ?? Date.now.timeIntervalSince1970,
            changeTimeIntervalSince1970: startTime != nil ? Date.now.timeIntervalSince1970 : nil
        )
    }

    private func createAlertController(toDoItem: ToDoItem) {
        let alertController = UIAlertController(
        title: "Дело",
        message: "Вы уверены, что хотите восстановить данное дело с новыми параметрами?",
        preferredStyle: .alert)

       let okAction = UIAlertAction(title: "Ok", style: .default, handler: { [weak self] _ in
           guard let self else { return }
           if let item = self.toDoItem {
               self.delegate?.updateTableView(showOrHideAncestor: self.showOrHideAncestor, method: .put, item: item)
               self.dismiss(animated: true)
           }
       })

       alertController.addAction(okAction)

       let cancelAction = UIAlertAction(title: "Cancel",
                                        style: .cancel,
                                        handler: { [weak self] _ in
           guard let self else { return }
           self.toDoItem = toDoItem
           self.tableView.reloadData()
       })

       alertController.addAction(cancelAction)

       self.present(alertController, animated: true)
       attempToRecoverItem = true
    }

    @objc private func leftBarButtonItemToDo() {
        print("Отменить")
        self.dismiss(animated: true)
    }

    @objc private func toDoIfHasText(_ notification: Notification) {
        let hasText = notification.userInfo?["hasText"] as? Bool ?? false
        if hasText {
            navigationItem.rightBarButtonItem?.tintColor = Colors.colorBlue.value
            navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            navigationItem.rightBarButtonItem?.tintColor = Colors.labelTeritary.value
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc func willShowKeyboard(_ notification: Notification) {
        guard let info = notification.userInfo as NSDictionary?,
              let keyboardSize = info.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as? NSValue else {return}

        let keyboardHeight = keyboardSize.cgRectValue.height
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight - 35, right: 0)
    }

    @objc func willHideKeyboard(_ notification: Notification) {
        tableView.contentInset = UIEdgeInsets.zero
    }

    @objc private func rotated() {
        guard let importanceCell = tableView.cellForRow(at: indexPathImportanceCell) as? ImportanceCell,
              let setDeadLineCell = tableView.cellForRow(at: indexPathSetDeadLineCell) as? SetDeadLineCell else {
            return
        }

        currentImportance = Importance
            .allCases[importanceCell.importanceSegmentedControl.selectedSegmentIndex]

        if let deadLineString = setDeadLineCell.deadLineLabel.text {
            currentDeadLine = dateFormatter.date(from: deadLineString)?.timeIntervalSince1970
        }

        isPortrait = UIDevice.current.orientation.isLandscape ? false : true

        tableView.reloadData()
    }
}

extension ItemViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return numberOfSection
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 || section == 2 ? 1 : countRowsInSecondSection
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        if indexPath == indexPathTextCell {

            guard let cell = tableView
                .dequeueReusableCell(
                    withIdentifier: TextCell.identifier,
                    for: indexPath
                ) as? TextCell else {
                preconditionFailure("TextCell can not be dequeued")
            }
            if let toDoItem = toDoItem {
                cell.textView.text = toDoItem.text
                cell.textView.textColor = Colors.labelPrimary.value

                NotificationCenter
                    .default
                    .post(
                        name: NSNotification.Name(rawValue: TextCell.notificationHasText),
                        object: nil,
                        userInfo: ["hasText": true]
                    )
            }
            cell.delegate = self
            return cell

        } else if indexPath == indexPathImportanceCell {

            guard let cell = tableView
                .dequeueReusableCell(
                    withIdentifier: ImportanceCell.indentifier,
                    for: indexPath
                ) as? ImportanceCell else {
                preconditionFailure("ImportanceCell can not be dequeued")
            }

            if let toDoItem = toDoItem {
                cell.importanceSegmentedControl.selectedSegmentIndex = Importance
                    .allCases
                    .firstIndex(of: toDoItem.importance) ?? 2
            }
            cell.isHidden = isPortrait ? false : true
            return cell

        } else if indexPath == indexPathSetDeadLineCell {

            guard let cell = tableView
                .dequeueReusableCell(
                    withIdentifier: SetDeadLineCell.identifier,
                    for: indexPath
                ) as? SetDeadLineCell else {
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
            cell.isHidden = isPortrait ? false : true
            return cell

        } else if countRowsInSecondSection == 3,
                  indexPath == indexPathCalendarCell {

            guard let cell = tableView
                .dequeueReusableCell(
                    withIdentifier: CalendarCell.identifier,
                    for: indexPath
                ) as? CalendarCell else {
                preconditionFailure("CalendarCell can not be dequeued")
            }
            cell.delegate = self
            cell.isHidden = isPortrait ? false : true
            return cell

        } else if indexPath == indexPathDeleteCell {

            guard let cell = tableView
                .dequeueReusableCell(
                    withIdentifier: DeleteCell.identifier,
                    for: indexPath
                ) as? DeleteCell else {
                preconditionFailure("DeleteCell can not be dequeued")
            }
            if toDoItem != nil {
                cell.deleteLabel.textColor = Colors.colorRed.value
            }
            cell.isHidden = isPortrait ? false : true
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
                  let textCell = tableView.cellForRow(at: indexPathTextCell) as? TextCell,
                  !textCell.textView.text.isEmpty,
                  textCell.textView.text != "Что надо сделать?" {
            if let item = self.toDoItem {
                delegate?.updateTableView(showOrHideAncestor: showOrHideAncestor, method: .delete, item: item)
            }
            self.dismiss(animated: true)
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

extension ItemViewController: TextCellHeightUpdatable {
    func updateTextCellHeight(to height: CGFloat) {
        guard let cell = tableView.cellForRow(at: indexPathTextCell) as? TextCell else { return }

        tableView.beginUpdates()
        cell.textViewHeightConstraint.constant = height
        tableView.endUpdates()
        tableView.scrollToRow(at: indexPathTextCell, at: .bottom, animated: false)
    }
}
