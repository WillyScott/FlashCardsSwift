//
//  CardViewController.swift
//  FlashCardSwift
//
//  Created by Scott Gromme on 4/13/17.
//  
//

import UIKit

class CardViewController: UIViewController {
    
    
    var set:Set!
    var card:Card!
    var coreDataStack:CoreDataStack!
    var cards:[Card]!
    var indexCards:Int!
    
    
    @IBOutlet weak var frontTextView: UITextView!
    
    @IBOutlet weak var backTextView: UITextView!

    @IBAction func yesNoButton(_ sender: UIButton) {
        if sender.titleLabel?.text == "Yes" {
            //print("button yes setting to no")
            sender.setTitle("No", for: .normal)
        } else {
            //print("button no setting to yes")
            sender.setTitle("Yes", for: .normal)
        }
    }
    
    @IBOutlet weak var yesNoButtonTitle: UIButton!
    
    @IBAction func tapGestureRecognizer(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @IBAction func saveButtonItem(_ sender: UIBarButtonItem) {
        //Save the new or existing FlashCard
        //Dont allow empty fields
        if frontTextView.text.isEmpty || backTextView.text.isEmpty {
            let alert = UIAlertController.init(title: "Alert", message: "Empty text field", preferredStyle: .alert)
            let cancelAlert  = UIAlertAction(title: "Cancel", style: .cancel)
            alert.addAction(cancelAlert)
            present(alert, animated: true)
        } else {
            print("Text exist for both front and back save the flashcard")
            //Save the card
            if let card = card {
                card.front = frontTextView.text
                card.back = backTextView.text
                card.show = valueShowCard()
                coreDataStack.saveContext()
            } else {
                let card = Card(context: (coreDataStack.managedContext))
                card.front = frontTextView.text
                card.back = backTextView.text
                card.show = valueShowCard()
                card.date = NSDate()
                set.addToCards(card)
                coreDataStack.saveContext()
        }
            _ = self.navigationController?.popViewController(animated: true)
        }

    }
    
    @IBAction func swipeRightGesture(_ sender: UISwipeGestureRecognizer) {
        
        //let swipeRight = SwipeLeftRight.right
        
        if title == "Editing Flashcard", let flashCards = cards {
            print("Swipe right recognized.")
            if indexCards - 1 >= 0 {
                print("swipe right")
                if frontTextView.text.isEmpty || backTextView.text.isEmpty {
                    //No empty text fields so dont do anything
                } else {
                    if let card = card {
                        card.front = frontTextView.text
                        card.back = backTextView.text
                        card.show = valueShowCard()
                        coreDataStack.saveContext()
                    }
                    indexCards = indexCards - 1
                    frontTextView.text = flashCards[indexCards].front
                    backTextView.text = flashCards[indexCards].back
                    if flashCards[indexCards].show {
                        yesNoButtonTitle.setTitle("Yes", for: .normal)
                    } else {
                        yesNoButtonTitle.setTitle("No", for: .normal)
                    }
                    card = flashCards[indexCards]
                }
            }
        }
    }
    
    @IBAction func swipeLeftGesture(_ sender: UISwipeGestureRecognizer) {
        print("Swipe left recogonized.")

        if title == "Editing Flashcard" , let flashCards = cards {
            print("left swipe detected")
            if indexCards + 1 < flashCards.count {
                if frontTextView.text.isEmpty || backTextView.text.isEmpty {
                    //No empty text fields so dont do anything
                } else {
                    if let card = card {
                        card.front = frontTextView.text
                        card.back = backTextView.text
                        card.show = valueShowCard()
                        coreDataStack.saveContext()
                    }
                    indexCards = indexCards + 1
                    frontTextView.text = flashCards[indexCards].front
                    backTextView.text = flashCards[indexCards].back
                    if flashCards[indexCards].show {
                        yesNoButtonTitle.setTitle("Yes", for: .normal)
                    } else {
                        yesNoButtonTitle.setTitle("No", for: .normal)
                    }
                    card = flashCards[indexCards]
                }
            }
       } else {
            print("ignore left swipe")
       }

    }

    
    func valueShowCard () -> Bool {
        if yesNoButtonTitle.titleLabel?.text == "Yes" {
            return true
        } else {
            return false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Adding a card or editing card
        if let card = card  {
            title = "Editing Flashcard"
            frontTextView.text = card.front!
            backTextView.text = card.back!
            if card.show {
                yesNoButtonTitle.setTitle("Yes", for: .normal)
            } else {
                yesNoButtonTitle.setTitle("No", for: .normal)
            }
        } else {
            title = "Adding Flashcard"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
