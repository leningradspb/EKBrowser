//
//  Extensions.swift
//  EKBrowser
//
//  Created by Eduard Kanevskii on 07.06.2023.
//

import UIKit

extension UIView {
    func addSubviews(_ subviews: [UIView]) {
        subviews.forEach { self.addSubview($0) }
    }
}
