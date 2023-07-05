//
//  ItemsListViewController.swift
//  ToDoList
//
//  Created by Даниил Кизельштейн on 27.06.2023.
//

import UIKit

class ItemsListViewController: UIViewController {

    // MARK: - Properties

    private lazy var tableView = UITableView(frame: .zero, style: .grouped)

    private lazy var addNewItemControl = AddNewItemControl()

    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM"
        dateFormatter.locale = Locale(identifier: "ru_RU")
        return dateFormatter
    }()

    private let fileCache = FileCache()

    private var items: [ToDoItem] = [ToDoItem]()

    private var rowsCount: Int {
        items.count
    }

    private var showOrHide: ShowAction = .show

    private let circleConfig = UIImage.SymbolConfiguration(pointSize: 22, weight: .bold, scale: .large)

    private var isPortrait: Bool = true

    // MARK: - Lifecircle

    override func viewDidLoad() {
        super.viewDidLoad()

        isPortrait = UIDevice.current.orientation.isLandscape ? false : true

        configureViewController()
        configureTableView()
        configureAddNewItemControl()

        do {
            try fileCache.loadItemsFromFileSystem(fileName: "test", type: .json)
            items = fileCache.items.filter({$0.isDone == false}).sorted { $0.startTime > $1.startTime}
        } catch let error {
            print(error)
        }

        NotificationCenter
            .default
            .addObserver(
                self,
                selector: #selector(saveItems),
                name: UIApplication.didEnterBackgroundNotification,
                object: nil)

        print(#function)
    }

    @objc private func saveItems() {
        do {
            try fileCache.saveItemsToFileSystem(fileName: "test", type: .json)
        } catch let error {
            print(error)
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.view.layer.backgroundColor = Colors.backPrimary.value.cgColor

    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Configure functions

    private func configureViewController() {
        self.view.layer.backgroundColor = Colors.backPrimary.value.cgColor

        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.layoutMargins = UIEdgeInsets(top: 88, left: 32, bottom: 0, right: 0)

        self.title = "Мои дела"
    }

    private func configureTableView() {
        tableView.backgroundColor = .clear

        tableView.separatorColor = Colors.supportSeparator.value

        tableView.separatorInset = UIEdgeInsets(top: 0, left: 52, bottom: 0, right: 0)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        ])

        tableView.dataSource = self
        tableView.delegate = self

        tableView.sectionHeaderTopPadding = 0

        tableView.register(ItemListCell.self, forCellReuseIdentifier: ItemListCell.identifier)
    }

    private func configureAddNewItemControl() {
        addNewItemControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(addNewItemControl)

        NSLayoutConstraint.activate([
            addNewItemControl.widthAnchor.constraint(equalToConstant: 44),
            addNewItemControl.heightAnchor.constraint(equalTo: addNewItemControl.widthAnchor),
            addNewItemControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addNewItemControl.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -54)
        ])

        addNewItemControl.delegate = self
    }

}

extension ItemsListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1 + rowsCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ItemListCell.identifier, for: indexPath) as? ItemListCell else {
            preconditionFailure("ItemListCell can not be dequeued")
        }
        cell.hidesTopSeparator = indexPath.row == 0
        cell.hidesBottomSeparator = indexPath.row == rowsCount

        cell.delegate = self

        if indexPath.row != rowsCount {

            let item = items[indexPath.row]

            cell.configureCell(
                rowInSection: 1+rowsCount,
                currentRow: indexPath.row,
                hasDeadLine: item.deadLine != nil ? true : false,
                lastCell: false)

            cell.configureBriefText(item: item)

            cell.configureDeadLineText(deadLine: item.deadLine, dateFormatter: dateFormatter)

        } else {
            cell.configureCell(rowInSection: 1+rowsCount, currentRow: indexPath.row, hasDeadLine: false, lastCell: true)

            cell.configureBriefTextDefault()
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let itemViewController = ItemViewController()
        itemViewController.fileCache = fileCache
        itemViewController.delegate = self
        itemViewController.showOrHideAncestor = showOrHide
        itemViewController.isPortrait = isPortrait
        if indexPath.row != rowsCount {
            itemViewController.toDoItem = items[indexPath.row]
        }
        self.navigationController?
            .present(UINavigationController(rootViewController: itemViewController), animated: true)
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.row == rowsCount || showOrHide == .hide ? false : true
    }

    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "")
        { [weak self] (action, view, completionHandler) in
            guard let self = self else { return }
            if indexPath.row != self.rowsCount {
                self.fileCache.appendItem(
                    ToDoItem(
                        id: self.items[indexPath.row].id,
                        text: self.items[indexPath.row].text,
                        importance: self.items[indexPath.row].importance,
                        deadLineTimeIntervalSince1970: nil,
                        isDone: true,
                        startTimeIntervalSince1970: self.items[indexPath.row].startTime.timeIntervalSince1970,
                        changeTimeIntervalSince1970: Date.now.timeIntervalSince1970)
                )
                self.items = self.fileCache.items.filter({$0.isDone == false}).sorted { $0.startTime > $1.startTime}

                NotificationCenter
                    .default
                    .post(
                        name: HeaderForSectionView.countDoneItemsChanged,
                        object: nil
                    )

                tableView.beginUpdates()
                tableView.deleteRows(at: [indexPath], with: .right)
                if indexPath.row == 0 {
                    tableView.reloadRows(at: [IndexPath(row: indexPath.row + 1, section: indexPath.section)], with: .left)
                }
                tableView.endUpdates()
            }
            completionHandler(true)
        }

        action.image = UIImage(systemName: "checkmark.circle.fill", withConfiguration: circleConfig)
        action.backgroundColor = Colors.colorGreen.value

        return UISwipeActionsConfiguration(actions: [action])
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "")
        { [weak self] (action, view, completionHandler) in
            guard let self = self else { return }
            if indexPath.row != self.rowsCount {
                self.fileCache.deleteItem(for: self.items[indexPath.row].id)
                self.items.remove(at: indexPath.row)
                tableView.beginUpdates()
                tableView.deleteRows(at: [indexPath], with: .fade)
                if indexPath.row == 0 {
                    tableView.reloadRows(at: [IndexPath(row: indexPath.row + 1, section: indexPath.section)], with: .fade)
                }
                tableView.endUpdates()
            }
            completionHandler(true)
        }

        action.image = UIImage(systemName: "trash.fill", withConfiguration: circleConfig)
        action.backgroundColor = Colors.colorRed.value

        return UISwipeActionsConfiguration(actions: [action])
    }
}

extension ItemsListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerForSectionView = HeaderForSectionView()
        headerForSectionView
            .configureView(
                countDoneItems: fileCache
                    .items
                    .map({$0.isDone})
                    .filter({$0 == true})
                    .count
            )
        headerForSectionView.showOrHideControl.delegate = self
        headerForSectionView.showOrHideControl.showOrHideLabel.text = showOrHide == .show ? "Показать" : "Скрыть"
        return headerForSectionView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        50
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        if UIDevice.current.orientation.isLandscape {
            isPortrait = false
        } else if UIDevice.current.orientation.isPortrait {
            isPortrait = true
        }

    }
}

extension ItemsListViewController: TableViewRowAppendable {
    func updateTableView(showOrHideAncestor: ShowAction) {
        if showOrHideAncestor == .hide {
            items = fileCache.items.sorted { $0.startTime > $1.startTime}
        } else {
            items = fileCache.items.filter({$0.isDone == false}).sorted { $0.startTime > $1.startTime}
        }
        tableView.reloadData()
    }
}

extension ItemsListViewController: ShowOrHideMakable {
    func whatToDo(action: ShowAction) {
        switch action {
        case .hide:
            showOrHide = .hide
            var itemsIsDoneWithDeadLine = fileCache.items.filter({$0.isDone == true})
            for index in 0..<itemsIsDoneWithDeadLine.count {
                let item = itemsIsDoneWithDeadLine[index]
                itemsIsDoneWithDeadLine[index] = ToDoItem(
                    id: item.id,
                    text: item.text,
                    importance: item.importance,
                    deadLineTimeIntervalSince1970: nil,
                    isDone: item.isDone,
                    startTimeIntervalSince1970: item.startTime.timeIntervalSince1970,
                    changeTimeIntervalSince1970: item.changeTime?.timeIntervalSince1970)
                fileCache.appendItem(itemsIsDoneWithDeadLine[index])
            }
            items = fileCache.items.sorted { $0.startTime > $1.startTime}
        case .show:
            showOrHide = .show
            items = fileCache.items.filter({$0.isDone == false}).sorted { $0.startTime > $1.startTime}
        }
        tableView.reloadData()
    }
}

extension ItemsListViewController: NewItemThroughCircleAddable {
    func addNewItemThroughCircle() {
        let itemViewController = ItemViewController()
        itemViewController.fileCache = fileCache
        itemViewController.delegate = self
        itemViewController.isPortrait = isPortrait
        self.navigationController?.present(UINavigationController(rootViewController: itemViewController), animated: true)
    }
}

extension ItemsListViewController: ItemIsDoneChangable {
    func itemIsDoneChanged(item: ToDoItem) {
        var deadlineTimeIntervalSince1970: Double?
        if let deadLine = item.deadLine?.timeIntervalSince1970 {
            deadlineTimeIntervalSince1970 = Date.now.timeIntervalSince1970 > deadLine ? nil : deadLine
        }
        let updateItem = ToDoItem(
            id: item.id,
            text: item.text,
            importance: item.importance,
            deadLineTimeIntervalSince1970: deadlineTimeIntervalSince1970,
            isDone: item.isDone ? false: true,
            startTimeIntervalSince1970: Date.now.timeIntervalSince1970,
            changeTimeIntervalSince1970: nil)

        fileCache.appendItem(updateItem)
        let currentItemIndex = self.items.firstIndex(where: { $0.id == item.id})
        self.items[currentItemIndex ?? 0] = updateItem
        guard let cell = tableView.cellForRow(at: IndexPath(row: currentItemIndex ?? 0, section: 0)) as? ItemListCell else { return }

        if showOrHide == .show {
            cell.item = updateItem
        } else {
            cell.configureBriefText(item: updateItem)
        }
    }
}
