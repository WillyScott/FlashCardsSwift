//
//  ExportViewController.swift
//  SwiftCard
//
//  Created by Scott Gromme on 7/26/17.
//  Copyright © 2017 Billys Awesome App House. All rights reserved.
//

import UIKit

class ExportViewController: UIViewController {

    
    @IBOutlet weak var textExportedView: UITextView!
    var exportedSetCVS: String?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let text = exportedSetCVS {
            textExportedView.text = text
        }
        
        // Do any additional setup after loading the view.
    }
}
