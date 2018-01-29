//
//  MyDocument.swift
//  SwiftCard
//
//  Created by Scott Gromme on 1/28/18.
//  Copyright © 2018 Billys Awesome App House. All rights reserved.
//

import UIKit

enum MyDocumentError:Error {
    case LoadError
}

class MyDocument:UIDocument {
    var documentText:String?
    
    
    override func contents(forType typeName: String) throws -> Any {
        if let text = documentText {
            let data = NSData(bytes: text, length: text.lengthOfBytes(using: String.Encoding.utf8))
            return data
        }else {
            return NSData()
        }
    }
    
    // function load
    // Conditional downcast from 'NSString?' to 'String' is a bridging conversion; did you mean to use 'as'?
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        if let content_data = contents as? Data {
            let length = content_data.count
            let stringEncoding = String.Encoding.utf8.rawValue
            documentText = NSString(bytes: (contents as AnyObject).bytes, length: length, encoding: stringEncoding) as String?
        } else {
            print("MyDocument.load error")
            throw MyDocumentError.LoadError
        }
    }

}
