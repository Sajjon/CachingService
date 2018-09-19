//
//  CoinView.swift
//  CachingService
//
//  Created by Alexander Cyon on 2017-12-14.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import UIKit
import ViewComposer
import TinyConstraints
import RxSwift
import CachingService
import RxCocoa

private let boldStyle: ViewStyle = [.font(.boldSystemFont(ofSize: 20))]
private let style: ViewStyle = [.font(.systemFont(ofSize: 20))]
final class CoinView: UIView {
    private let bag = DisposeBag()
    private let viewModel: DetailedCoinInfoViewModel

    private lazy var symbolLabels = labels("Symbol", keyPath: \.symbol)
    private lazy var nameLabels = labels("Name", keyPath: \.name)
    private lazy var totalSupplyLabels = labels("Total Supply", keyPath: \.totalSupply)
    private let getPriceButton: UIButton = [.text("Get price")]
    
    private var views: [UIView] { return [symbolLabels, nameLabels, totalSupplyLabels, .spacer] }
    private lazy var stackView: StackView = [.views(views), .axis(.vertical), .marginsRelative(true)]^
    
    init(coin: Coin, coinService: CoinServiceProtocol) {
        self.viewModel = DetailedCoinInfoViewModel(
            coin: coin,
            coinService: coinService,
            trigger: getPriceButton.rx.tap.asDriver()
        )
        super.init(frame: .zero)
        setupViews()
        setupBindings()
    }

    func setupBindings() {
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit { log.debug("") }
}

private extension CoinView {
    func setupViews() {
        backgroundColor = .white
        addSubview(stackView)
        stackView.edgesToSuperview()
    }
    
    func labels(_ text: String, keyPath: KeyPath<DetailedCoinInfoViewModel, Driver<String>>) -> LabelsView {
        let driver = viewModel[keyPath: keyPath]
        let labels = LabelsView(title: boldStyle <- [.text(text)], value: style, style: [.axis(.horizontal)])
        driver.drive(labels.rx.value).disposed(by: bag)
        return labels
    }
}

final class DetailedCoinInfoViewModel {

    let coin: Driver<Coin>
    var symbol: Driver<String> { return coin.map { $0.symbol } }
    var totalSupply: Driver<String> { return coin.map { $0.totalSupplyString }  }
    var coinId: Driver<String> { return coin.map { $0.id } }
    var name: Driver<String> { return coin.map { $0.name } }

    init(coin: Coin, coinService: CoinServiceProtocol, trigger: Driver<Void>) {
        self.coin = trigger.withLatestFrom(coinService.getCoinPrice(for: coin, fromSource: .default).asDriverOnErrorReturnEmpty())

    }
}

public extension ObservableType {

    func asDriverOnErrorReturnEmpty() -> Driver<E> {
        return asDriver { _ in
            return Driver.empty()
        }
    }
}
