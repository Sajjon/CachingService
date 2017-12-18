//
//  View.swift
//  CachingService
//
//  Created by Alexander Cyon on 2017-12-14.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import UIKit
import ViewComposer

public class View: UIView, Composable {
    public typealias Style = ViewStyle
    
    let style: ViewStyle
    
    public required init(_ style: ViewStyle? = nil) {
        let style = style.merge(slave: .default)
        self.style = style
        super.init(frame: .zero)
        compose(with: style)
    }
    
    /// Important, do not remove this!
    public func setupSubviews(with style: ViewStyle) { /* Do not remove this, it allows for usage of `setupSubviews` in subclasses */ }
    
    public required init?(coder: NSCoder) { requiredInit }
}

private extension ViewStyle {
    @nonobjc static let `default`: ViewStyle = []
}

extension UIView {
    @nonobjc static var spacer: View { return spacer() }
    static func spacer(_ color: UIColor = .clear, _ maybeHeight: CGFloat? = nil) -> View {
        var style: ViewStyle = [.color(color)]
        if let someHeight = maybeHeight {
            style = style <<- .height(someHeight)
        }
        return View(style)
    }
}
