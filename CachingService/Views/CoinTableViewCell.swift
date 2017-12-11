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
    private lazy var nameLabel: UILabel = [.color(.red)]
    private lazy var coinImageView: UIImageView = [.color(.blue), .contentMode(.scaleAspectFit), .clipsToBounds(true), .width(bounds.height)]
    private lazy var stackView: UIStackView = [.spacing(20), .horizontalMargin(16)]
        <<- .views([self.coinImageView, self.nameLabel])
    
    private let bag = DisposeBag()
    var viewModel: CoinViewModel?
    
    //MARK: Initialization
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) { requiredInit }
    
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
        nameLabel.text = viewModel.coin.name
        viewModel.image.observeOn(MainScheduler.instance)
        .subscribe(onNext: {
            switch $0 {
            case .content(image: let image): self.coinImageView.image = image
            case .offlinePlaceholder: log.warning("offline placeholder")
            }
        }, onError: { log.error("Failed to download image, error: `\($0)`") }
        ).disposed(by: bag)
    }
}

final class CoinViewModel {
    let coin: Coin
    let imageService: ImageService
    lazy var image: Observable<DownloadableImage> = self.imageService.imageFromURL(self.coin.imageUrl)
    init(coin: Coin, imageService: ImageService) {
        self.coin = coin
        self.imageService = imageService
    }
}
