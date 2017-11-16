//
//  Presentable.swift
//  SingleRxSignal
//
//  Created by Alexander Cyon on 2017-11-16.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import UIKit
import RxSwift

protocol Presentable {
    func present(on presentor: Presentor, presentation: Presentation)
}

extension Presentable {
    func present(on presentor: Presentor, presentation: Presentation) {
        presentor.present(self, presentation: presentation)
    }
}

typealias Completion = () -> Void
enum PresentationStyle {
    case push
    case modal(Completion)
}

protocol Presentation {
    var animated: Bool { get }
    var style: PresentationStyle { get }
}

struct PushPresentation: Presentation {
    let animated: Bool
    let style: PresentationStyle = .push
    init(animated: Bool) {
        self.animated = animated
    }
}
