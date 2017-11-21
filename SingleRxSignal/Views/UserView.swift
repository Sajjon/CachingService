//
//  UserView.swift
//  SingleRxSignal
//
//  Created by Alexander Cyon on 2017-11-16.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation
import ViewComposer
import TinyConstraints
import RxSwift

private let stackViewStyle: ViewStyle = [.axis(.vertical), .distribution(.fillEqually), .verticalMargin(150)]

final class UserView: UIView {
    
    private var getButton: UIButton = [.text("Get"), .textColor(.green)]
    private var clearButton: UIButton = [.text("Clear Cache"), .textColor(.red)]
    private var nameLabel: UILabel = [.textAlignment(.center), .text("Waiting for user to be fetched...")]
    private var stackView: UIStackView
    let viewModel: UserViewModel
    private let bag = DisposeBag()
    
    init(userService: UserServiceProtocol) {
        self.viewModel = UserViewModel(
            userService: userService,
            getButton: getButton.rx.tap.asObservable(),
            clearButton: clearButton.rx.tap.asObservable()
        )
        stackView = stackViewStyle <- .views([nameLabel, getButton, clearButton])
        super.init(frame: .zero)
        setupViews()
        setupBindings()
    }
    
    func setupViews() {
        addSubview(stackView)
        stackView.edgesToSuperview()
        backgroundColor = .white
    }
    
    func setupBindings() {
        func debugPrint(_ message: String) {
            threadTimePrint("SUBSCRIBER: \(message)")
        }
        
        viewModel.userResponse.subscribe(onNext: {
            debugPrint("Got user: `\($0)`")
            self.nameLabel.text = $0.name
        }, onError: {
            debugPrint("Error: `\($0)`")
        }, onCompleted: {
            debugPrint("Completed")
        }, onDisposed: {
            debugPrint("Disposed")
        }).disposed(by: bag)
        
        viewModel.isFetching.subscribe(onNext: { isFetching in
            guard isFetching else { return }
            self.nameLabel.text = "Fetching..."
        }).disposed(by: bag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("die")
    }
}
