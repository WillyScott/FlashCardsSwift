//
//  ExportViewController.swift
//  SwiftCard
//
//  Created by Scott Gromme on 7/26/17.
//  Copyright © 2017 Billys Awesome App House. All rights reserved.
//

import UIKit

class ExportViewController: UIViewController {
    
    var exportedSetCVS: String?
    var exportedSetJSON: String?
    var viewTitle = "Export"
    
    @IBOutlet weak var textViewExport: UITextView!
    
    @IBAction func csvJsonButton(_ sender: UIBarButtonItem) {
        if (sender.title == "CSV") {
            sender.title = "JSON"
            let text = exportedSetCVS ?? ""
            textViewExport.text = text
        } else {
            sender.title = "CSV"
            let text = exportedSetJSON ?? ""
            textViewExport.text = text
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = viewTitle
        //print("ExportViewController.viewDidLoad()")
        let text = exportedSetJSON ?? ""
        textViewExport.text = text
    }
    
}
