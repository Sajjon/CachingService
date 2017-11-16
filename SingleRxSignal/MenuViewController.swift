//
//  MenuViewController.swift
//  SingleRxSignal
//
//  Created by Alexander Cyon on 2017-11-16.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import UIKit
import ViewComposer
import RxSwift
import RxCocoa

private let cellId = "cellId"
final class MenuViewController {
    
    private lazy var tableView: UITableView = [.dataSourceDelegate(self.dataSource)]
        <- .registerCells([CellClass(UITableViewCell.self, cellId)])
    
    private lazy var dataSource: TableViewDataSource = TableViewDataSource(models: [UserViewController(userService: userService)].map { $0 as AbstractViewController }, presentor: self.presentor)
    
    private let userService: UserServiceProtocol
    var presentor: Presentor?
    init(userService: UserServiceProtocol, presentor: Presentor?) {
        self.userService = userService
        self.presentor = presentor
    }
    
    deinit {
        print("deinit of MenuViewController")
    }
}

extension MenuViewController: AbstractViewController {
    var rootView: UIView { return tableView }
}

private final class TableViewDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    typealias Model = AbstractViewController
    private let models: [Model]
    private var presentor: Presentor?
    init(models: [Model], presentor: Presentor?) {
        self.models = models
        self.presentor = presentor
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        if let model = model(at: indexPath) {
            cell.textLabel?.text = model.title
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let model = model(at: indexPath) else { return }
        let abstract: AbstractViewController = model
        presentor?.present(abstract, presentation: PushPresentation(animated:true))
    }
    
    func model(at indexPath: IndexPath) -> Model? {
        guard indexPath.row < models.count else { return nil }
        return models[indexPath.row]
    }
}

