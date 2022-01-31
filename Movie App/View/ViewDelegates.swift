//
//  ViewDelegates.swift
//  Movie App
//
//  Created by BS198 on 31/1/22.
//

import UIKit

protocol ScrollViewDelegate: AnyObject {
    static var identifier: String { get }
    static func nib() -> UINib
}
