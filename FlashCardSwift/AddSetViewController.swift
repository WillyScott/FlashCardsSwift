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

    // MARK: Adds new Set
    @objc func addSet ( sender: UIBarButtonItem?) {
        
        var currentSet:Set?
        let fetchRequestSet:NSFetchRequest<Set> = Set.fetchRequest()
        let predicateSet = NSPredicate(format: "%K == %@", #keyPath(Set.name), setName.text! )
        fetchRequestSet.predicate = predicateSet
        //Set names must be unique
        do {
            let results = try coreDataStack.managedContext.fetch(fetchRequestSet)
            if results.count > 0  || results.count < 2{
                currentSet = results.first
            } else if results.count > 1 {
                assertionFailure()
            }
        } catch let error as NSError {
            print("Fetch error: \(error) description \(error.userInfo)")
        }
        
        //TextField and TextView are not allowed to be empty
        if setDescription.text.isEmpty || setName.text!.isEmpty {
            print("Empty text not allowed")
            let alert = UIAlertController(title: "Alert", message: "Empty text field", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "OK", style: .cancel)
            alert.addAction(cancelAction)
            present(alert, animated: true)
        } else {
            
            // Set is being edited
            if let set = set {
                guard let coreDataStack = coreDataStack else { return }
                if set.name == setName.text {
                    
                    set.name = setName.text
                    set.descriptionSet = setDescription.text
                    // Assign the set description set it to "" if left blank
                    if let _ = setSection.text {
                        set.section = setSection.text
                    } else {
                        set.section = ""
                    }
                    //TODO set to "" if empty
                    if let _ = importURL.text {
                        set.importURL = importURL.text
                    }
                    set.randomize = booleanRandomizeCards(randomCardsButton)
                    coreDataStack.saveContext()
                    _ = self.navigationController?.popViewController(animated: true)
                    
                } else {  // Text field changed to a existing set and is not allowed
                    
                    if let set = currentSet {
                        let alert = UIAlertController(title: "Alert", message: "Set Name - \(String(describing: set.name)) is not unique", preferredStyle: .alert)
                        let cancelAction = UIAlertAction(title: "OK", style: .cancel)
                        alert.addAction(cancelAction)
                        present(alert, animated: true)
                    } else {
                        set.name = setName.text
                        set.descriptionSet = setDescription.text
                        if let _ = setSection.text {
                            set.section = setDescription.text
                        } else {
                            set.section = ""
                        }
                        //TODO set to "" if empty
                        if let _ = importURL.text {
                            set.importURL = importURL.text
                        }
                        set.randomize = booleanRandomizeCards(randomCardsButton)
                        coreDataStack.saveContext()
                        _ = self.navigationController?.popViewController(animated: true)
                    }
                }
            } else {  // Set is new
            
                //Create and save the new Set
                // If managedObjectContext is not initialized return
                
                if let _ = currentSet {
                    let alert = UIAlertController(title: "Alert", message: "Set Name - \(setName.text!) is not unique", preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title: "OK", style: .cancel)
                    alert.addAction(cancelAction)
                    present(alert, animated: true)
                    
                } else {
                    guard let coreDataStack = coreDataStack else { return }
                    let set = Set(context: coreDataStack.managedContext)
                    set.name = setName.text
                    set.descriptionSet = setDescription.text
                    set.date = NSDate()
                    if let _ = setSection.text {
                        set.section = setSection.text
                    } else {
                        set.section = ""
                    }
                    //TODO:  set import url to "" is nothing entered
                    if let _ = importURL.text {
                        set.importURL = importURL.text
                    }
                    set.randomize = booleanRandomizeCards(randomCardsButton)
                    coreDataStack.saveContext()
                _ = self.navigationController?.popViewController(animated: true)
                }
            }
         }
    }
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

