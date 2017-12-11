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
private let itemHeight: CGFloat = 50
final class CoinsView: UIView {
    
    private let statusLabel: UILabel = [.textAlignment(.center), .text("Idle"), .font(.boldSystemFont(ofSize: 24)), .height(itemHeight)]
    
    private let getFromCacheAndBackendButton: UIButton = [.text("Get: cache+backend"), .textColor(.white), .color(.green), .font(.boldSystemFont(ofSize: 20)), .height(itemHeight)]
    
    private let clearCacheButton: UIButton = [.text("Clear cache"), .textColor(.white), .color(.red), .font(.systemFont(ofSize: 18)), .height(itemHeight)]
    
    private let getFromCacheButton: UIButton = [.text("Get: cache"), .textColor(.white), .color(.blue), .font(.systemFont(ofSize: 18)), .height(itemHeight)]
    
    private let clearTableViewButton: UIButton = [.text("Clear TableView"), .textColor(.black), .color(.yellow), .font(.systemFont(ofSize: 18)), .height(itemHeight)]
    
    private lazy var views: [UIView] = [statusLabel, getFromCacheAndBackendButton, getFromCacheButton, clearCacheButton, clearTableViewButton]
    private lazy var stackView: UIStackView = [.views(self.views), .axis(.vertical)]
    
    private lazy var tableView: UITableView = [.dataSourceDelegate(self), .rowHeight(50)]
        <- .registerCells([CellClass(CoinTableViewCell.self, cellId)])
    
    var presenter: Presenter?
    let viewModel: CoinsViewModel
    
    private let imageService: ImageService
    
    private let bag = DisposeBag()
    typealias ViewModel = CoinViewModel
    private var viewModels = [ViewModel]() {
        didSet { tableView.reloadData() }
    }
    
    init(
        coinService: CoinServiceProtocol,
        imageService: ImageService,
        presenter: Presenter?) {
        self.viewModel = CoinsViewModel(
            coinService: coinService,
            getFromCacheAndBackendButton: getFromCacheAndBackendButton.rx.tap.asObservable(),
            getFromCacheOnlyButton: getFromCacheButton.rx.tap.asObservable(),
            clearCacheButton: clearCacheButton.rx.tap.asObservable(),
            clearModelsButton: clearTableViewButton.rx.tap.asObservable()
        )
        self.presenter = presenter
        self.imageService = imageService
        super.init(frame: .zero)
        setupViews()
        
        setupBindings()
    }
    
    func setupBindings() {
        
        viewModel.models.subscribe(onNext: {
            log.debug("Got #\($0.count) coins")
            self.viewModels = $0.map { CoinViewModel(coin: $0, imageService: self.imageService) }
        }, onError: {
            log.error("Error: `\($0)`")
        }, onCompleted: {
            log.verbose("Completed")
        }, onDisposed: {
            log.verbose("Disposed")
        }).disposed(by: bag)

        viewModel.isFetching.bind(to: UIApplication.shared.rx.isNetworkActivityIndicatorVisible).disposed(by: bag)
        
        viewModel.isFetching.subscribe(onNext: { isFetching in
            self.statusLabel.text = isFetching ? "Fetching..." : (self.viewModels.isEmpty ? "Idle" : "Got #\(self.viewModels.count) coins")
        }).disposed(by: bag)
    }
    
    required init?(coder aDecoder: NSCoder) { requiredInit }
}

private extension CoinsView {
    func setupViews() {
        addSubview(tableView)
        tableView.edgesToSuperview()
        stackView.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: itemHeight * CGFloat(stackView.arrangedSubviews.count))
        stackView.translatesAutoresizingMaskIntoConstraints = true
        tableView.tableHeaderView = stackView
    }
}

extension CoinsView: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rowCount = viewModels.count
        log.info("#\(rowCount) rows")
        return rowCount
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

