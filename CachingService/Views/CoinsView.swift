//
//  CoinsView.swift
//  CachingService
//
//  Created by Alexander Cyon on 2017-12-02.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import UIKit
import ViewComposer
import RxSwift
import RxCocoa

private let cellId = "cellId"
final class CoinsView: UIView {
    
    private let getButton: UIButton = [.text("Get"), .textColor(.green)]
    private let clearButton: UIButton = [.text("Clear Cache"), .textColor(.red)]
    private let statusLabel: UILabel = [.textAlignment(.center), .text("Waiting for user to be fetched...")]
    private lazy var stackView: UIStackView = [.views([self.statusLabel, self.getButton, self.clearButton]), .axis(.vertical)]
    private lazy var tableView: UITableView = [.dataSourceDelegate(self), .rowHeight(50)]
        <- .registerCells([CellClass(CoinTableViewCell.self, cellId)])
    
    var presenter: Presenter?
    let viewModel: CoinsViewModel
    
    private let imageService: ImageService
    
    private let bag = DisposeBag()
    typealias ViewModel = CoinViewModel
    private var viewModels = [ViewModel]() {
        didSet {
            statusLabel.text = "Got \(viewModels.count) coins"
            tableView.reloadData()
        }
    }

    init(
        coinService: CoinServiceProtocol,
        imageService: ImageService,
        presenter: Presenter?) {
        self.viewModel = CoinsViewModel(
            coinService: coinService,
            getButton: getButton.rx.tap.asObservable(),
            clearButton: clearButton.rx.tap.asObservable()
        )
        self.presenter = presenter
        self.imageService = imageService
        super.init(frame: .zero)
        setupViews()
        
        setupBindings()
    }
    
    func setupBindings() {
        log.debug("settin up bindings")
        viewModel.coinResponse.subscribe(onNext: {
            log.debug("Got #\($0.count) coins")
            self.viewModels = $0.map { CoinViewModel(coin: $0, imageService: self.imageService) }
        }, onError: {
            log.error("Error: `\($0)`")
        }, onCompleted: {
            log.verbose("Completed")
        }, onDisposed: {
            log.verbose("Disposed")
        }).disposed(by: bag)
        
        viewModel.isFetching.subscribe(onNext: { isFetching in
            guard isFetching else { return }
            self.statusLabel.text = "Fetching..."
        }).disposed(by: bag)
    }
    
    required init?(coder aDecoder: NSCoder) { requiredInit }
}

private extension CoinsView {
    func setupViews() {
        addSubview(tableView)
        tableView.edgesToSuperview()
        stackView.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 100)
        stackView.translatesAutoresizingMaskIntoConstraints = true
        tableView.tableHeaderView = stackView
    }
}

extension CoinsView: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        if let coinCell = cell as? CoinTableViewCell, let coinViewModel = viewModel(at: indexPath) {
            coinCell.configure(with: coinViewModel)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        log.warning("Push coin view")
        //        guard let model = model(at: indexPath) else { return }
//        presenter?.present(model, presentation: PushPresentation(animated:true))
    }
    
    func viewModel(at indexPath: IndexPath) -> ViewModel? {
        guard indexPath.row < viewModels.count else { return nil }
        return viewModels[indexPath.row]
    }
}

