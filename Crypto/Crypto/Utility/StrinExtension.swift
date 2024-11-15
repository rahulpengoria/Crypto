//
//  StrinExtension.swift
//  Crypto
//
//  Created by Rahul Pengoria on 15/11/24.
//

import UIKit

extension String {
    func width(withFont font: UIFont) -> CGFloat {
        let attributes = [NSAttributedString.Key.font: font]
        return self.size(withAttributes: attributes).width
    }
}
