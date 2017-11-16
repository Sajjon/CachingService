//
//  MenuView.swift
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
final class MenuView: UIView {
    
    private lazy var tableView: UITableView = [.color(.red), .dataSourceDelegate(self)]
        <- .registerCells([CellClass(UITableViewCell.self, cellId)])
    
    private let userService: UserServiceProtocol
    var presenter: Presenter?
    typealias Model = AbstractViewController
    private let models: [Model]
    init(userService: UserServiceProtocol, presenter: Presenter?) {
        self.userService = userService
        self.presenter = presenter
        models = [UserViewController(userService: userService)].map { $0 as AbstractViewController }
        super.init(frame: .zero)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("die")
    }
}

private extension MenuView {
    func setupViews() {
        addSubview(tableView)
        tableView.edgesToSuperview()
    }
}

extension MenuView: UITableViewDataSource, UITableViewDelegate {

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
        presenter?.present(model, presentation: PushPresentation(animated:true))
    }
    
    func model(at indexPath: IndexPath) -> Model? {
        guard indexPath.row < models.count else { return nil }
        return models[indexPath.row]
    }
}

