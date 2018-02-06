//
//  ViewController.swift
//  FlashCardSwift
//
//  Created by Scott Gromme on 2/24/17.
//  
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    
    
    private let emptyDatabase = "No Flashcard Sets"
    private let sequeAddSetViewController = "SegueAddSet"
    fileprivate let segueEditSetViewController = "SegueEditSet"
    private let sequeCardViewController = "SequeCardsViewController"
    fileprivate var indexPathSegue: IndexPath?
    private var set:Set!
    // coreDataStack is initialized in AppDelegate.swift
    var coreDataStack: CoreDataStack!
    fileprivate  var fetchResultsSetsController: NSFetchedResultsController<Set>!
    // Use to add up cards marked not shown
    var fetchRequest: NSFetchRequest<Set>?
    var sets: [Set] = []
    
    // MARK: IBActions
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBAction func helpInformaton(_ sender: UIBarButtonItem) { }
    
    // MARK: UIViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any? ) {
        
        if segue.identifier == sequeAddSetViewController {
            let addSetViewController = segue.destination as! AddSetViewController
            addSetViewController.coreDataStack = coreDataStack
        } else  if let indexPath = tableView.indexPathForSelectedRow,  segue.identifier == sequeCardViewController{
            let  cardsViewController = segue.destination as! CardsViewController
            cardsViewController.coreDataStack = coreDataStack
            cardsViewController.set = fetchResultsSetsController.object(at: indexPath)
         } else if  segue.identifier ==   segueEditSetViewController {
            let addSetViewController = segue.destination as! AddSetViewController
            addSetViewController.coreDataStack = coreDataStack
            addSetViewController.set = fetchResultsSetsController.object(at: indexPathSegue!)
        } else  {
            print("Unknown segue identifer")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        // fetchrequest in model
        guard let model =
        coreDataStack.managedContext.persistentStoreCoordinator?.managedObjectModel,
        let fetchRequest = model.fetchRequestTemplate(forName: "FetchRequestSet") as? NSFetchRequest<Set> else {
            print("Error assigning model or fetchRequest" )
            return
        }
        self.fetchRequest = fetchRequest
        updateSetsCardsNotShow()
        reloadData()
        tableView.reloadData()
        setupView()
    }
    
    override func viewDidLoad() {
        //print("ViewController.ViewDidLoad")
        super.viewDidLoad()
        title = "Flashcard Sets"
        reloadData()
        tableView.reloadData()
        setupView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        //save the update to sets  countshow field
        coreDataStack.saveContext()
    }
    
    //MARK: functions
    
    //If Sets is empty View will display text
    fileprivate func updateView () {
        messageLabel.text =  emptyDatabase
        var hasSets = false
        if let sets = fetchResultsSetsController.fetchedObjects {
            hasSets = sets.count > 0
        }
        tableView.isHidden = !hasSets
        messageLabel.isHidden = hasSets
        activityIndicator.stopAnimating()
    }
    
    private func setupView() {
        messageLabel.text =  emptyDatabase
        updateView()
    }
    
    private func reloadData() {
        let fetchRequest: NSFetchRequest<Set> = Set.fetchRequest()
        // FetchRequest require sort descriptors
        // TODO: sort by section
        let sort = NSSortDescriptor(key: #keyPath(Set.section), ascending: false)
        fetchRequest.sortDescriptors = [sort]
        fetchResultsSetsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: coreDataStack.managedContext, sectionNameKeyPath: #keyPath(Set.section), cacheName: nil)
        fetchResultsSetsController.delegate = self
        
        do {
            try fetchResultsSetsController.performFetch()
        } catch let error as NSError {
            print("Fetching error: \(error), \(error.userInfo)")
        }
        
        // Count each sets cards that are show is marked false
        // save the update just before the ViewController is removed
        let setsAll = fetchResultsSetsController.fetchedObjects
//        let setsAllCount = setsAll?.count ?? 0
//        print("ViewController.reloadData")
//        print("sets count: " + String(setsAllCount))
        for set in setsAll! {
            var cardCountNotShow:Int32 = 0
            for card in set.cards! {
                // cast as Card
                if let card = card as? Card {
                    let show = card.show
                    if show == false {
                        cardCountNotShow = cardCountNotShow + 1
                    }

                } else {
                    print("not able to cast to Card")
                }
 
            }
            set.countShow = cardCountNotShow
//            print("value of countShow is: " + String(cardCountNotShow))
        }
    }
}

extension ViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let sections = fetchResultsSetsController.sections else {
            return 0
        }
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionInfo = fetchResultsSetsController.sections?[section]
        return sectionInfo?.name
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionInfo = fetchResultsSetsController.sections?[section] else {
            return 0
        }
        return sectionInfo.numberOfObjects
    }
  
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SetTableViewCell.reuseIdentifier, for: indexPath) as? SetTableViewCell else{
            fatalError("Unexpected Index Path"  )
        }
        
        let set = fetchResultsSetsController.object(at: indexPath)
        let cardCount = String(set.countShow) + "/" + String(set.cards?.count ?? 0)
        // TODO:  these assignments are not being used see func configure()
        cell.cardsLabel.text = cardCount
        cell.setDescription.text = set.descriptionSet
        cell.setLabel.text = set.name
        cell.setSection.text = set.section
        // cell color
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 8
        cell.clipsToBounds = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        // TODO: delete these commits
//        if editingStyle == .delete {
//            print("delete editing style")
//        } else {
//            print("No insertions")
//        }
    }
    
    func configure( _ cell: SetTableViewCell, at indexPath: IndexPath) {
        //Fetch Set
        let setCurrent = fetchResultsSetsController.object(at: indexPath)
        cell.cardsLabel.text = String(setCurrent.countShow) + "/" + String(setCurrent.cards?.count ?? 0)
        cell.setDescription.text = setCurrent.descriptionSet
        cell.setLabel.text = setCurrent.name
        cell.setSection.text = setCurrent.section
    }
}

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    // Different way to allow table editing.
//    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        guard let setSwiped = fetchResultsSetsController?.object(at: indexPath) else {return nil}
//        let deleteAction = UIContextualAction(style: .destructive, title: "Delete"){
//            [weak self] (action , view , completionHandler) in
//            guard let `self` = self else {
//                completionHandler(false)
//                return
//            }
//            setSwiped.managedObjectContext?.delete(setSwiped)
//            self.coreDataStack.saveContext()
//            completionHandler(true)
//        }
//        deleteAction.backgroundColor = UIColor.red
//        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
//        return configuration
//    }
//
//    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        guard let setSwiped = fetchResultsSetsController?.object(at: indexPath) else {return nil}
//        let editAction = UIContextualAction(style: .normal, title: "Edit") {
//            [weak self] (action, view, completionHandler) in
//            guard let `self` = self else {
//                completionHandler(false)
//                return
//            }
//            // segue to the edit set
//            print("Edit set should go to segue")
//            completionHandler(true)
//        }
//        editAction.backgroundColor = UIColor.green
//        let configuration = UISwipeActionsConfiguration(actions: [editAction])
//        return configuration
//    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { (action, indexPath) in
            self.isEditing = false
            let set = self.fetchResultsSetsController.object(at: indexPath)
            set.managedObjectContext?.delete(set)
            self.coreDataStack.saveContext()
            //tableView.reloadData()
        }
        delete.backgroundColor = UIColor.red

        let edit = UITableViewRowAction (style: .normal, title: "Edit") { (action, indexPath) in
            self.isEditing = false
            self.indexPathSegue = indexPath
            self.performSegue(withIdentifier: self.segueEditSetViewController, sender: self)
        }
        edit.backgroundColor = UIColor.gray
        return [edit, delete]
    }
}

extension ViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch (type) {
        case NSFetchedResultsChangeType.delete:
            tableView.deleteSections(IndexSet(integer:sectionIndex), with: .fade)
        case .insert:
            tableView.insertSections(IndexSet(integer:sectionIndex), with: .fade)
        case .update:
            break
        case .move:
            break
        }
    }
    
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        //causes error 2 lines
        print("controller")
        tableView.endUpdates()
        updateView()
        tableView.reloadData()
    }
    
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch (type) {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
            break;
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        case .update:
            if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) as? SetTableViewCell {
                configure(cell, at: indexPath)
            }
            break;
        default:
           print("default")
        }
    }
    
    
  
}
// TODO:  remove if not needed
extension ViewController {
    func updateSetsCardsNotShow() {
    }
}

