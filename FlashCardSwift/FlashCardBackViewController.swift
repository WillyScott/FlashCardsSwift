//
//  FlashCardBackViewController.swift
//  FlashCardSwift
//
//  Created by Scott Gromme on 4/18/17.
//  
//

import UIKit

class FlashCardBackViewController: UIViewController {
    
    var card: Card!
    
    @IBOutlet weak var backFlashCard: UILabel!
    @IBAction func tapDismissPressed(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
  
    override func viewDidLoad() {
        super.viewDidLoad()
        backFlashCard.lineBreakMode = .byWordWrapping
        backFlashCard.numberOfLines = 0
        backFlashCard.text = card.back

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
