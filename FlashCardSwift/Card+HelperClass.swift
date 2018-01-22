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
    // converts Card front and back to strings replacing newlines returns with "\n"
    // replaces " with "" and replaces , with \,
    func csv () -> String {
        
        let frontString = front ?? ""
        let backString = back ?? ""
        var frontStringMod = frontString.replacingOccurrences(of: "\n", with: "\\n")
        frontStringMod = frontStringMod.replacingOccurrences(of: "\"", with: "\"\"")
        frontStringMod = frontStringMod.replacingOccurrences(of: ",", with: "\\,")
        var backStringMod = backString.replacingOccurrences(of: "\"", with: "\"\"")
        backStringMod = backStringMod.replacingOccurrences(of: "\n", with: "\\n")
        backStringMod = backStringMod.replacingOccurrences(of: ",", with: "\\,")
        return "\"" + frontStringMod + "\"" + "," + "\"" + backStringMod  + "\"" + "\n"
    }
    
}
     
