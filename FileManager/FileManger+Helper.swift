//
//  FileManger+Helper.swift
//  SwiftCard
//
//  Created by Scott Gromme on 1/23/18.
//  Copyright © 2018 Billys Awesome App House. All rights reserved.
//

import Foundation

public extension FileManager {
    static var documentDirectoryURL: URL {
        return try! FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false)
    }
    
}
