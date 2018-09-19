//
//  LabelsView.swift
//  CachingService
//
//  Created by Alexander Cyon on 2017-12-14.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import UIKit
import ViewComposer

extension Makeable where Self.Styled == Self, Self.Style.Attribute == ViewAttribute {
    init(_ style: ViewStyle) {
        self = Self.make(style.attributes)
    }
}

public final class LabelsView: View {
    private let titleLabel: UILabel
    fileprivate let valueLabel: UILabel
    private let stackView: StackView
    
    public init(
        title titleStyle: ViewStyle,
        value valueStyle: ViewStyle,
        style: ViewStyle? = nil
        ) {
        let style = style.merge(slave: .default)
        titleLabel = UILabel(titleStyle)
        valueLabel = UILabel(valueStyle)
        stackView = style <<- [.views([titleLabel, valueLabel]), .baselineRelative(true)]
        super.init(style)
        compose(with: style)
    }
    
    public override func setupSubviews(with style: ViewStyle) {
        addSubview(stackView)
        setupConstraints()
        if let textAlignment: NSTextAlignment = style.value(.textAlignment) {
            titleLabel.textAlignment = textAlignment
            valueLabel.textAlignment = textAlignment
        }
    }
    
    public required init?(coder: NSCoder) { requiredInit }
    public required init(_ style: ViewStyle?) { requiredInit }
    
    public func updateValueLabel(text: String) {
        valueLabel.text = text
    }
}

import RxCocoa
import RxSwift
extension Reactive where Base == LabelsView {
    var value: Binder<String?> {
        return base.valueLabel.rx.text
    }
}


private extension LabelsView {
    func setupConstraints() {
        stackView.edgesToSuperview()
    }
}

private extension ViewStyle {
    @nonobjc static let `default`: ViewStyle = [.axis(.vertical), .spacing(4), .distribution(.fillEqually)]
}
