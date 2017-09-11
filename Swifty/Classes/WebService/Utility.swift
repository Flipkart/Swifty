//
//  Utility.swift
//  Pods
//
//  Created by Siddharth Gupta on 16/03/17.
//
//

import Foundation

extension NSNumber {
    internal var isBool: Bool { return CFBooleanGetTypeID() == CFGetTypeID(self) }
}
