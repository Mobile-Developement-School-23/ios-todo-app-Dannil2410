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
    private let userDefaults = UserDefaults.standard

    private var items: [ToDoItem] = [ToDoItem]()
//    private var serverItems: [ToDoItem]?
    private var serverItems: [ToDoItem] = [ToDoItem]()

    private var rowsCount: Int {
        items.count
    }

    private var showOrHide: ShowAction = .show

    private let circleConfig = UIImage.SymbolConfiguration(pointSize: 22, weight: .bold, scale: .large)

    private var isPortrait: Bool = true

    private let networkService = DefaultNetworkingService(
        deviceId: UIDevice.current.identifierForVendor?.uuidString ?? ""
    )

    private lazy var downloadAnimationView: DownloadAnimationView = {
        let downloadAnimationView = DownloadAnimationView()
        downloadAnimationView.backgroundColor = .clear
        return downloadAnimationView
    }()

    // MARK: - Lifecircle

    override func viewDidLoad() {
        super.viewDidLoad()

        isPortrait = UIDevice.current.orientation.isLandscape ? false : true

        configureViewController()
        configureTableView()
        configureAddNewItemControl()
        configureDownloadAnimationView()
        setUpDownloadAnimation()

        NotificationCenter
            .default
            .addObserver(
                self,
                selector: #selector(saveItems),
                name: UIApplication.didEnterBackgroundNotification,
                object: nil)

        do {
            try fileCache.loadItemsFromFileSystem(fileName: "test", type: .json)
            items = fileCache.items.filter({$0.isDone == false}).sorted { $0.startTime > $1.startTime}
        } catch let error {
            print(error)
        }

        firstSynchronization()
    }

    @objc private func saveItems() {
        do {
            if networkService.isDirty {
                try fileCache.saveItemsToFileSystem(fileName: "test", type: .json)

            }
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

    private func configureDownloadAnimationView() {
        downloadAnimationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(downloadAnimationView)

        NSLayoutConstraint.activate([
            downloadAnimationView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            downloadAnimationView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            downloadAnimationView.widthAnchor.constraint(equalToConstant: 60),
            downloadAnimationView.heightAnchor.constraint(equalTo: downloadAnimationView.widthAnchor, multiplier: 1/3)
        ])
    }

    private func setUpDownloadAnimation() {
        downloadAnimationView.isHidden = false
        downloadAnimationView.firstCircle.backgroundColor = .gray
        downloadAnimationView.secondCircle.backgroundColor = .gray
        downloadAnimationView.thirdCircle.backgroundColor = .gray
        UIView.animate(withDuration: 1,
                       delay: 0,
                       options: [.autoreverse, .repeat],
                       animations: { [self] in
            downloadAnimationView.firstCircle.alpha = 0
        })
        UIView.animate(withDuration: 1,
                       delay: 0.5,
                       options: [.autoreverse, .repeat],
                       animations: { [self] in
            downloadAnimationView.secondCircle.alpha = 0
        })
        UIView.animate(withDuration: 1,
                       delay: 1,
                       options: [.autoreverse, .repeat],
                       animations: { [self] in
            downloadAnimationView.thirdCircle.alpha = 0
        })
    }

    private func cancelDownloadAnimation() {
        downloadAnimationView.firstCircle.layer.removeAllAnimations()
        downloadAnimationView.secondCircle.layer.removeAllAnimations()
        downloadAnimationView.thirdCircle.layer.removeAllAnimations()

        downloadAnimationView.firstCircle.backgroundColor = .clear
        downloadAnimationView.secondCircle.backgroundColor = .clear
        downloadAnimationView.thirdCircle.backgroundColor = .clear

        downloadAnimationView.isHidden = true
    }

}

extension ItemsListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1 + rowsCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView
            .dequeueReusableCell(
                withIdentifier: ItemListCell.identifier,
                for: indexPath
            ) as? ItemListCell else {
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
        itemViewController.delegate = self
        itemViewController.showOrHideAncestor = showOrHide
        itemViewController.isPortrait = isPortrait
        if indexPath.row != rowsCount {
            itemViewController.toDoItem = items[indexPath.row]
        }
        self.navigationController?
            .present(UINavigationController(rootViewController: itemViewController), animated: true)
    }

    func tableView(
        _ tableView: UITableView,
        leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "") { [weak self] (_, _, completionHandler) in
            guard let self = self else { return }
            if indexPath.row != self.rowsCount {
                let isDoneItem = ToDoItem(
                    id: self.items[indexPath.row].id,
                    text: self.items[indexPath.row].text,
                    importance: self.items[indexPath.row].importance,
                    deadLineTimeIntervalSince1970: nil,
                    isDone: true,
                    startTimeIntervalSince1970: self.items[indexPath.row].startTime.timeIntervalSince1970,
                    changeTimeIntervalSince1970: Date.now.timeIntervalSince1970)
                if self.networkService.isDirty {
                    self.fileCache.appendItem(isDoneItem)
                } else if let index = FileCache.firstIndexOf(id: isDoneItem.id, in: self.serverItems) {
                    self.serverItems[index] = isDoneItem
                }

                self.postOrPutToServer(method: .put, item: isDoneItem)
                NotificationCenter
                    .default
                    .post(
                        name: HeaderForSectionView.countDoneItemsChanged,
                        object: nil
                    )

                self.items = (self.networkService.isDirty
                              ? self.fileCache.items
                              : self.serverItems)
                .filter({$0.isDone == false}).sorted { $0.startTime > $1.startTime }
//                tableView.beginUpdates()
//                self.items = (self.networkService.isDirty
//                              ? self.fileCache.items
//                              : self.serverItems)
//                .filter({$0.isDone == false}).sorted { $0.startTime > $1.startTime }
//
//                tableView.deleteRows(at: [indexPath], with: .right)
//                if indexPath.row == 0 {
//                    tableView
//                        .reloadRows(at: [IndexPath(row: indexPath.row + 1, section: indexPath.section)], with: .left)
//                }
//                tableView.endUpdates()

                tableView.reloadData()
            }
            completionHandler(true)
        }

        action.image = UIImage(systemName: "checkmark.circle.fill", withConfiguration: circleConfig)
        action.backgroundColor = Colors.colorGreen.value

        if indexPath.row == rowsCount || showOrHide == .hide {
            return nil
        }
        return UISwipeActionsConfiguration(actions: [action])
    }

    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "") { [weak self] (_, _, completionHandler) in
            guard let self = self else { return }
            if indexPath.row != self.rowsCount {
                let deletedItem = self.items.remove(at: indexPath.row)
                if self.networkService.isDirty {
                    self.fileCache.deleteItem(for: deletedItem.id)
                } else if let index = FileCache.firstIndexOf(id: deletedItem.id, in: self.serverItems) {
                    self.serverItems.remove(at: index)
                }
                self.deleteItemFromServer(deletedItem: deletedItem)
//                tableView.beginUpdates()
//                tableView.deleteRows(at: [indexPath], with: .fade)
//                if indexPath.row == 0 {
//                    tableView
//                        .reloadRows(at: [IndexPath(row: indexPath.row + 1, section: indexPath.section)], with: .fade)
//                }
//                tableView.endUpdates()
                tableView.reloadData()
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
                countDoneItems: (networkService.isDirty ? fileCache.items : serverItems)
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
    func updateTableView(showOrHideAncestor: ShowAction, method: RequestMethod, item: ToDoItem) {
        toDoChangeInLists(method: method, item: item)

        switch method {
        case .delete:
            deleteItemFromServer(deletedItem: item)
        default:
            postOrPutToServer(method: method, item: item)
        }

        if networkService.isDirty {
            items = (showOrHideAncestor == .hide
                     ? fileCache.items
                     : fileCache.items.filter({$0.isDone == false}))
            .sorted { $0.startTime > $1.startTime}
        } else {
            items = (showOrHideAncestor == .hide
                     ? serverItems
                     : serverItems.filter({$0.isDone == false}))
            .sorted { $0.startTime > $1.startTime}
        }
        tableView.reloadData()
    }

    private func toDoChangeInLists(method: RequestMethod, item: ToDoItem) {
        if !networkService.isDirty {
            if method == .delete,
               let index = FileCache.firstIndexOf(id: item.id, in: serverItems) {
                self.serverItems.remove(at: index)
            } else if let index = FileCache.firstIndexOf(id: item.id, in: serverItems) {
                self.serverItems[index] = item
            } else {
                self.serverItems.append(item)
            }
        } else {
            if method == .delete {
                fileCache.deleteItem(for: item.id)
            } else {
                fileCache.appendItem(item)
            }
        }
    }
}

extension ItemsListViewController: ShowOrHideMakable {
    func changeConditionUsing(action: ShowAction) {
        switch action {
        case .hide:
            showOrHide = .hide
            var itemsIsDoneWithDeadLine = (networkService.isDirty
                                           ? fileCache.items
                                           : serverItems)
                .filter({$0.isDone == true})
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
                if networkService.isDirty {
                    fileCache.appendItem(itemsIsDoneWithDeadLine[index])
                } else if let firstIndexOf = FileCache.firstIndexOf(id: item.id, in: serverItems) {
                    serverItems[firstIndexOf] = itemsIsDoneWithDeadLine[index]
                }
            }
            items = (networkService.isDirty ? fileCache.items : serverItems)
                .sorted { $0.startTime > $1.startTime}
        case .show:
            showOrHide = .show
            items = (networkService.isDirty ? fileCache.items : serverItems)
                .filter({$0.isDone == false})
                .sorted { $0.startTime > $1.startTime}
        }
        tableView.reloadData()
    }
}

extension ItemsListViewController: NewItemThroughCircleAddable {
    func addNewItemThroughCircle() {
        let itemViewController = ItemViewController()
        itemViewController.delegate = self
        itemViewController.isPortrait = isPortrait
        self.navigationController?
            .present(
                UINavigationController(
                    rootViewController: itemViewController
                ),
                animated: true
            )
    }
}

extension ItemsListViewController: ItemIsDoneChangable {
    func itemIsDoneChangedCondition(_ item: ToDoItem) {
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

        if networkService.isDirty {
            fileCache.appendItem(updateItem)
        } else if let index = FileCache.firstIndexOf(id: updateItem.id, in: serverItems) {
            self.serverItems[index] = updateItem
        }

        postOrPutToServer(method: .put, item: updateItem)

        let currentItemIndex = self.items.firstIndex(where: { $0.id == item.id})
        self.items[currentItemIndex ?? 0] = updateItem

        guard let cell = tableView
            .cellForRow(
                at: IndexPath(row: currentItemIndex ?? 0, section: 0)
            ) as? ItemListCell else { return }

        if showOrHide == .show {
            cell.item = updateItem
        } else {
            cell.configureBriefText(item: updateItem)
        }
    }
}

extension ItemsListViewController {

    // MARK: - Requests to server

    func firstSynchronization() {
        Task {
            do {
                if fileCache.items.count > 0 {
                    serverItems = try await networkService.patch(for: fileCache.items)
                    fileCache.deleteAll()
                } else {
                    serverItems = try await networkService.fetchItems()
                }
                items = serverItems.filter({ $0.isDone == false }).sorted { $0.startTime > $1.startTime}
                await MainActor.run(body: {
                    cancelDownloadAnimation()
                    self.tableView.reloadData()
                })
            } catch let error as RequestError {
                if error == .serverError {
                    await MainActor.run(body: {
                        cancelDownloadAnimation()
                        self.show(message: error.localizedDescription)
                    })
                }
            } catch let error {
                networkService.isDirty = true
                await MainActor.run(body: {
                    cancelDownloadAnimation()
                    if error.localizedDescription == "The request timed out." {
                        presentError(error: error)
                    }
                })
            }
        }
    }

    func deleteItemFromServer(deletedItem: ToDoItem) {
        Task {
            var isDifferentRevision = false
            do {
                if self.networkService.isDirty {
                    serverItems = try await self.networkService.patch(for: self.fileCache.items)
                    fileCache.deleteAll()
                }
                try await self.networkService.delete(for: deletedItem)
            } catch let error as RequestError {
                if error == .wrongRequest {
                    isDifferentRevision = true
                } else if error == .serverError {
                    serverItems.forEach { item in fileCache.appendItem(item) }
                    await MainActor.run(body: { self.show(message: error.localizedDescription) })
                }
            } catch { networkService.isDirty = true }
            if isDifferentRevision {
                await toDoIfDifferentRevision(item: deletedItem)
            }
        }
    }

    func postOrPutToServer(method: RequestMethod, item: ToDoItem) {
        Task {
            var isDifferentRevision = false
            do {
                if networkService.isDirty {
                    serverItems = try await networkService.patch(for: fileCache.items)
                    fileCache.deleteAll()
                }
                switch method {
                case .post: try await networkService.post(for: item)
                case .put: try await networkService.put(for: item)
                default: break
                }
            } catch let error as RequestError {
                if error == .wrongRequest {
                    isDifferentRevision = true
                } else if error == .serverError {
                    serverItems.forEach { item in fileCache.appendItem(item) }
                    await MainActor.run(body: { self.show(message: error.localizedDescription) })
                }
            } catch { networkService.isDirty = true }
            if isDifferentRevision {
                await toDoIfDifferentRevision(method: method, item: item)
            }
        }
    }

    func toDoIfDifferentRevision(method: RequestMethod = .delete, item: ToDoItem) async {
        do {
            let fetchItems = try await networkService.fetchItems()
            switch method {
            case .delete:
                if fetchItems.contains(where: {$0.id == item.id }) {
                    try await networkService.delete(for: item)
                }
            case .post:
                try await networkService.post(for: item)
            case .put:
                try await networkService.put(for: item)
            }
        } catch let error as RequestError {
            if error == .serverError {
                serverItems.forEach { item in fileCache.appendItem(item) }
            }
            await MainActor.run(body: { show(message: error.localizedDescription) })
        } catch { networkService.isDirty = true }
    }

    private func presentError(error: Error) {
        self.show(message: error.localizedDescription
                  + " Maybe you have bad connection. Check it out!"
        )
    }
}
