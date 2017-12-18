//
//  CoinTableViewCell.swift
//  CachingService
//
//  Created by Alexander Cyon on 2017-12-04.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import UIKit
import ViewComposer
import TinyConstraints
import RxSwift

var requiredInit: Never { fatalError("required init") }

final class CoinTableViewCell: UITableViewCell {
    private lazy var nameLabel: UILabel = [.font(UIFont.systemFont(ofSize: 20))]
    private lazy var coinImageView: UIImageView = [.contentMode(.scaleAspectFit), .clipsToBounds(true), .width(bounds.height)]
    private lazy var stackView: UIStackView = [.spacing(20), .horizontalMargin(16)]
        <<- .views([self.coinImageView, self.nameLabel])
    
    private var bag: DisposeBag?
    var viewModel: CoinViewModel?
    
    //MARK: Initialization
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) { requiredInit }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        coinImageView.image = nil
        viewModel = nil
        bag = nil
    }
    
    func configure(with viewModel: CoinViewModel) {
        self.viewModel = viewModel
        populateViews(with: viewModel)
    }
}

private extension CoinTableViewCell {
    
    func setupViews() {
        contentView.addSubview(stackView)
        stackView.edgesToSuperview()
    }
    
    func populateViews(with viewModel: CoinViewModel) {
        let bag = DisposeBag()
        nameLabel.text = viewModel.name
        viewModel.image.observeOn(MainScheduler.instance)
        .subscribe(onNext: {
            self.coinImageView.image = $0
        }, onError: { log.error("Failed to download image, error: `\($0)`") }
        ).disposed(by: bag)
        self.bag = bag
    }
}

final class CoinViewModel {
    private let coin: Coin
    
    var coinId: String { return coin.coinId }
    var symbol: String { return coin.symbol }
    var name: String { return coin.name }
    var totalSupply: String { return coin.totalSupplyString }
    
    let imageService: ImageServiceProtocol
    lazy var image: Observable<Image> = self.imageService.imageFromURL(self.coin.imageUrl)
    init(coin: Coin, imageService: ImageServiceProtocol) {
        self.coin = coin
        self.imageService = imageService
    }
}
