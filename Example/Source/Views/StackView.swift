//
//  StackView.swift
//  CachingService
//
//  Created by Alexander Cyon on 2017-12-14.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import UIKit
import ViewComposer
import TinyConstraints

public final class StackView: UIStackView, Composable {
    let style: ViewStyle
    var backgroundColorView: UIView?
    
    public init(_ style: ViewStyle? = nil) {
        let style = style.merge(slave: .default)
        self.style = style
        super.init(frame: .zero)
        compose(with: style)
    }
    
    public required init(coder: NSCoder) { requiredInit }
}

//MARK: - Composable
public extension StackView {
    func setupSubviews(with style: ViewStyle) {
        setupArrangedSubviews(with: style)
        setupBackgroundView(with: style)
    }
}

public extension StackView {
    func setupBackgroundView(with style: ViewStyle) {
        if let backgroundColor: UIColor = style.value(.color) {
            setupBackgroundView(with: backgroundColor)
        }
    }
    
    func setupBackgroundView(with color: UIColor) {
        let backgroundColorView = UIView()
        backgroundColorView.translatesAutoresizingMaskIntoConstraints = false
        backgroundColorView.backgroundColor = color
        addSubview(backgroundColorView)
        sendSubview(toBack: backgroundColorView)
        backgroundColorView.edgesToSuperview()
        self.backgroundColorView = backgroundColorView
    }
}

private extension ViewStyle {
    @nonobjc static let `default`: ViewStyle = [.axis(.vertical)]
}
