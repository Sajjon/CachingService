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
import CachingService

private let cellId = "cellId"
private let itemHeight: CGFloat = 50
private let style: ViewStyle = [.font(.boldSystemFont(ofSize: 18)), .textColor(.black), .height(itemHeight)]
final class CoinsView: UIView {
    
    private let statusLabel: UILabel = style <<- [.textAlignment(.center), .text("Idle"), .font(.boldSystemFont(ofSize: 24))]
    
    private let getFromCacheAndBackendButton: UIButton = style <<- [.text("⬇️ Cache+Backend"), .textColor(.white), .color(.green)]
    
    private let getFromCacheButton: UIButton = style <<- [.text("⬇️ Cache"), .textColor(.white), .color(.blue)]

    private let clearCacheButton: UIButton = [.text("🗑 Models"), .textColor(.white), .color(.red), .font(.systemFont(ofSize: 18)), .height(itemHeight)]
    
    private let clearTableViewButton: UIButton = [.text("❌ TableView"), .textColor(.black), .color(.yellow), .font(.systemFont(ofSize: 18)), .height(itemHeight)]
    
    private let clearImageCacheButton: UIButton = [.text("❌ Images"), .textColor(.black), .color(.orange), .font(.systemFont(ofSize: 18)), .height(itemHeight)]
    
    private lazy var getButtonsStackView: UIStackView = [.views([self.getFromCacheAndBackendButton, self.getFromCacheButton]), .axis(.horizontal), .distribution(.fillEqually)]
    private lazy var clearButtonsStackView: UIStackView = [.views([self.clearCacheButton, self.clearTableViewButton]), .axis(.horizontal), .distribution(.fillEqually)]
   
    private let filterBar: UISearchBar = [.placeholder("Filter coins")]
    
    private lazy var views: [UIView] = [statusLabel, getButtonsStackView, clearButtonsStackView, clearImageCacheButton, filterBar]
    private lazy var stackView: UIStackView = [.views(self.views), .axis(.vertical)]
    
    private lazy var tableView: UITableView = [.dataSourceDelegate(self), .rowHeight(itemHeight), .keyboardDismissMode(.onDrag)]
        <- .registerCells([CellClass(CoinTableViewCell.self, cellId)])
    
    var presenter: Presenter?
    let viewModel: CoinsViewModel
    
    private let imageService: ImageServiceProtocol
    private let coinService: CoinServiceProtocol

    private let bag = DisposeBag()
    typealias ViewModel = CoinViewModel
    private var viewModels = [ViewModel]() {
        didSet { tableView.reloadData() }
    }
    
    init(
        coinService: CoinServiceProtocol,
        imageService: ImageServiceProtocol,
        presenter: Presenter?) {
        self.viewModel = CoinsViewModel(
            coinService: coinService,
            getFromCacheAndBackendButton: getFromCacheAndBackendButton.rx.tap.asObservable(),
            getFromCacheOnlyButton: getFromCacheButton.rx.tap.asObservable(),
            clearCacheButton: clearCacheButton.rx.tap.asObservable(),
            clearModelsButton: clearTableViewButton.rx.tap.asObservable(),
            filterBar: filterBar.rx.text.asObservable().nilIfEmpty
        )
        self.presenter = presenter
        self.imageService = imageService
        self.coinService = coinService
        super.init(frame: .zero)
        setupViews()
        
        setupBindings()
    }
    
    func setupBindings() {
        viewModel.models.subscribe(onNext: {
            self.viewModels = $0.map { CoinViewModel(coin: $0, imageService: self.imageService) }
        }, onError: {
            self.statusLabel.text = "Error: `\($0)`"
        }).disposed(by: bag)


        viewModel.isFetching.bind(to: UIApplication.shared.rx.isNetworkActivityIndicatorVisible).disposed(by: bag)
        
        viewModel.isFetching.subscribe(onNext: { isFetching in
            self.statusLabel.text = isFetching ? "Fetching..." : (self.viewModels.isEmpty ? "Idle" : "Got #\(self.viewModels.count) coins")
        }).disposed(by: bag)
        
        clearImageCacheButton.rx.tap.asObservable().flatMapLatest({ _ in
            self.imageService.deleteAllImages()
        }).subscribe().disposed(by: bag)
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
        guard let coinViewModel = viewModel(at: indexPath) else { return }
        let coinViewController = CoinViewController(coin: coinViewModel.coin, coinService: coinService)
        presenter?.present(coinViewController, presentation: PushPresentation(animated:true))
    }
    
    func viewModel(at indexPath: IndexPath) -> ViewModel? {
        guard indexPath.row < viewModels.count else { return nil }
        return viewModels[indexPath.row]
    }
}

