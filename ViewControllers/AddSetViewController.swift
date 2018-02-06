//
//  AddSetViewController.swift
//  FlashCardSwift
//
//  Created by Scott Gromme on 3/2/17.
//  //

import UIKit
import CoreData


class AddSetViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var setName: UITextField!
    @IBOutlet weak var setDescription: UITextView!
    @IBOutlet weak var importURL: UITextField!
    @IBOutlet weak var setSection: UITextField!
    @IBOutlet weak var randomCardsButton: UIButton!
    @IBAction func randomCard(_ sender: UIButton) {
        if sender.titleLabel?.text == "False" {
           sender.setTitle("True", for: .normal)
        } else {
           sender.setTitle("False", for: .normal)
        }
    }
   
    var coreDataStack: CoreDataStack!
    var set: Set?
    
    // MARK: IBAction
    @IBAction func tapGesterRecognizer(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Add Set"
        // Do any additional setup after loading the view.
        // Add the save button - could do this in the Main.storyboard
        let action = #selector(AddSetViewController.addSet )
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: action)
        //Update the textfields if editing a Set
        if let set = set {
            title = "Editing Set"
            setName.text = set.name
            setDescription.text = set.descriptionSet
            importURL.text = set.importURL
            setSection.text = set.section
            if set.randomize {
               randomCardsButton.setTitle("True", for: .normal)
            } else {
               randomCardsButton.setTitle("False", for: .normal)
            }
        }
    }

    // MARK: Save Button pressed -  A IBAction can be added for this saved button
    @objc func addSet ( sender: UIBarButtonItem?) {

        // Save the set if it is editing or add a new set if it is new
        if let set = set {
            guard let coreDataStack = coreDataStack else { return }
            // Assign values is available set to "" if left blank
            if let _ = setName.text {
                set.name = setName.text
            } else {
                set.name = ""
            }
            if let _ = setDescription.text {
                set.descriptionSet = setDescription.text
            } else {
                set.descriptionSet = ""
            }
            let section = setSection.text ?? ""
            if section.count > 0 {
                set.section = section
            } else {
                set.section = "NoSet"
            }

            if let _ = importURL.text {
                set.importURL = importURL.text
            } else {
                set.importURL = ""
            }
            set.randomize = booleanRandomizeCards(randomCardsButton)
            coreDataStack.saveContext()
            _ = self.navigationController?.popViewController(animated: true)
        } else {
            
            guard let coreDataStack = coreDataStack else { return }
            let set = Set(context: coreDataStack.managedContext)
            if let _ = setName.text {
                set.name = setName.text
            } else {
                set.name = ""
            }
            if let _ = setDescription.text {
                set.descriptionSet = setDescription.text
            } else {
                set.descriptionSet = ""
            }
            set.date = NSDate()
            let section = setSection.text ?? ""
            
            if section.count > 0 {
                set.section = section
            } else {
                set.section = "NoSet"
            }
            //TODO:  set import url to "" is nothing entered
            if let _ = importURL.text {
                set.importURL = importURL.text
            } else {
                set.importURL = ""
            }
            set.randomize = booleanRandomizeCards(randomCardsButton)
            coreDataStack.saveContext()
            _ = self.navigationController?.popViewController(animated: true)
         }
    }
    
    // MARK: functions
    func booleanRandomizeCards(_ randomCardsButton: UIButton) -> Bool {
        if randomCardsButton.titleLabel?.text == "False" {
            return false
        } else {
            return true        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

