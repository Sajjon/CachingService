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

private let boldStyle: ViewStyle = [.font(.boldSystemFont(ofSize: 20))]
private let style: ViewStyle = [.font(.systemFont(ofSize: 20))]
final class CoinView: UIView {

    private let viewModel: CoinViewModel

    private lazy var symbolLabels = labels("Symbol", keyPath: \.symbol)
    private lazy var nameLabels = labels("Name", keyPath: \.name)
    private lazy var totalSupplyLabels = labels("Total Supply", keyPath: \.totalSupply)
    
    private var views: [UIView] { return [symbolLabels, nameLabels, totalSupplyLabels, .spacer] }
    private lazy var stackView: StackView = [.views(views), .axis(.vertical), .marginsRelative(true)]^
    
    init(viewModel: CoinViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupViews()
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
    
    func labels(_ text: String, keyPath: KeyPath<CoinViewModel, String>) -> LabelsView {
        let value = viewModel[keyPath: keyPath]
        return LabelsView(title: boldStyle <- [.text(text)], value: style <- .text(value), style: [.axis(.horizontal)])
    }
}
