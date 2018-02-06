//
//  FlashCardFrontViewController.swift
//  FlashCardSwift
//
//  Created by Scott Gromme on 4/18/17.
//  
//

import UIKit

class FlashCardFrontViewController: UIViewController {
    
    var card: Card!
    var pageIndex: Int!
    var count: Int!
    var coreDataStack: CoreDataStack!
    var titleOfCard: String?
    var segueFlashCardBackViewController = "SegueBackFlashCard"
    
    // MARK: IBActions and IBOutlets
    @IBOutlet weak var frontFlashCard: UILabel!
    @IBOutlet weak var pageLabel: UILabel!
    @IBOutlet weak var topHolderLabel: UILabel!
    @IBOutlet weak var bottomHolderLabel: UILabel!
    @IBAction func swipeShowtoFalse(_ sender: UISwipeGestureRecognizer) {
        card.show = false
        coreDataStack.saveContext()
        showCard.text = "Know it!"
        
    }
    @IBAction func tapToFlashCardBackViewController(_ sender: UITapGestureRecognizer) {
        //print("tap recognized")
        performSegue(withIdentifier: segueFlashCardBackViewController, sender: self )
    }
    @IBAction func swipeShowtoTrue(_ sender: UISwipeGestureRecognizer) {
        card.show = true
        coreDataStack.saveContext()
        showCard.text = ""
        
    }
    @IBOutlet weak var showCard: UILabel!

    // MARK: FlashCardFrontViewController functions.
    override func viewDidLoad() {
        super.viewDidLoad()
        topHolderLabel.text = ""
        bottomHolderLabel.text = ""
        if card.show == true {
            showCard.text = ""
        }
        frontFlashCard.lineBreakMode = .byWordWrapping
        frontFlashCard.numberOfLines = 0
        frontFlashCard.text = card.front
        if let index = pageIndex, let num = count {
            pageLabel.text = String(describing: index + 1) + " of " + String(describing: num)
            //title = String(describing: index + 1) + " of " + String(describing: num)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueFlashCardBackViewController, let flashCardBackViewController = segue.destination as? FlashCardBackViewController {
            flashCardBackViewController.card = card
        }
    }
}
