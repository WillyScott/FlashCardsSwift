//
//  Card+HelperClass.swift
//  SwiftCard
//
//  Created by Scott Gromme on 7/26/17.
//  Copyright © 2017 Billys Awesome App House. All rights reserved.
//

import Foundation
import CoreData  

extension Card {
    
    func csv () -> String {
        let frontString = front ?? ""
        let frontStringMod = frontString.replacingOccurrences(of: "\"",with: "\"\"")
        let backString = back ?? ""
        let backStringMod = backString.replacingOccurrences(of: "\"", with: "\"\"")
        return "\"" + frontStringMod + "\"" + "," + "\"" + backStringMod  + "\"" + "\n"
    }
    
}
     
