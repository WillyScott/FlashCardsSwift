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

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBAction func helpInformaton(_ sender: UIBarButtonItem) {
        
    }
    
    private let emptyDatabase = "No Flashcard Sets"
    private let sequeAddSetViewController = "SegueAddSet"
    fileprivate let segueEditSetViewController = "SegueEditSet"
    private let sequeCardViewController = "SequeCardsViewController"
    fileprivate var indexPathSegue: IndexPath?
    private var set:Set!
    // coreDataStack is initialized in AppDelegate.swift
    var coreDataStack: CoreDataStack!
    fileprivate  var fetchResultsSetsController: NSFetchedResultsController<Set>!
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
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
    
    private func reloadData() {
        let fetchRequest: NSFetchRequest<Set> = Set.fetchRequest()
        // FetchRequest require sort descriptors
        // TODO: sort by section
        let sort = NSSortDescriptor(key: #keyPath(Set.date), ascending: true)
        fetchRequest.sortDescriptors = [sort]
        fetchResultsSetsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: coreDataStack.managedContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchResultsSetsController.delegate = self
        
        do {
            try fetchResultsSetsController.performFetch()
        } catch let error as NSError {
            print("Fetching error: \(error), \(error.userInfo)")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sets = fetchResultsSetsController.fetchedObjects else {
            return 0
        }
        return sets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SetTableViewCell.reuseIdentifier, for: indexPath) as? SetTableViewCell else{
            fatalError("Unexpected Index Path"  )
        }
        
        let set = fetchResultsSetsController.object(at: indexPath)
        cell.cardsLabel.text = String(set.cards?.count ?? 0)
        cell.setDescription.text = set.descriptionSet
        cell.setLabel.text = set.name
        cell.setSection.text = set.section
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            print("delete editing style")
//        } else {
//            print("No insertions")
//        }
    }
    
    func configure( _ cell: SetTableViewCell, at indexPath: IndexPath) {
        //Fetch Set
        let setCurrent = fetchResultsSetsController.object(at: indexPath)
        cell.cardsLabel.text = String(setCurrent.cards?.count ?? 0)
        cell.setDescription.text = setCurrent.descriptionSet
        cell.setLabel.text = setCurrent.name
        cell.setSection.text = setCurrent.section
    }
}

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { (action, indexPath) in
            self.isEditing = false
            let set = self.fetchResultsSetsController.object(at: indexPath)
            set.managedObjectContext?.delete(set)
            self.coreDataStack.saveContext()
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
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        tableView.beginUpdates()
        
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
        updateView()
        
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

