//
//  CardsViewController.swift
//  FlashCardSwift
//
//  Created by Scott Gromme on 3/17/17.
//  View Controller that displays all the cards in a set
//  The cards can be added, deleted or editied
//  from this view controller the bottom button bar adds major functionality
//  to this app
//  All Core Data changes are commited when they happen.  This is by design.
//  vs saving in one place.

import UIKit
import CoreData
import GameplayKit


// Private error codes
private enum CardsViewControllerErrorCodes: Int {
    case serverConnectionFailed = 101
    case extractingJSONFailed = 102
    case processingJSONFailed = 103
    case commitingDataCoreDataFailed = 104
}

class CardsViewController: UITableViewController , NSFetchedResultsControllerDelegate   {
    
    //Passed in Via Segue
    var coreDataStack: CoreDataStack?
    var set: Set?
    
    var fetchResultsController: NSFetchedResultsController<Card>?
    var cardSortDescriptor: NSSortDescriptor?
    var cardNamePredicate: NSPredicate?
    var cardShowPredicate: NSPredicate?
    var cardPredicates: NSCompoundPredicate?
    var cardsShuffled:[Card]?
    var exportCVS:String?
    var exportJSON:String?
    
    private let segueEditCard = "SegueEditCard"
    private let segueAddNewCard = "SegueNewCard"
    private let seguePageViewController = "SeguePageView"
    private let segueExport = "SegueExport"
    fileprivate var indexPathSeque: IndexPath?
    
    
    // MARK: IBActions
    @IBAction func ExportButtonItem(_ sender: UIBarButtonItem) {
        exportCVS = ExportData()
        exportJSON = exportCardsToJson()
        performSegue(withIdentifier: segueExport, sender: sender)
    }
  
    // Function resets cards show field to true if show field is false
    // it wont show up in the flashcards
    @IBAction func resetCardsShowtoTrue(_ sender: UIBarButtonItem) {
        let count = fetchResultsController?.fetchedObjects?.count  ?? 0
        if count > 0 {
            if let cards = fetchResultsController?.fetchedObjects {
                for i in 0 ..< count {
                    cards[i].show = true
                }
                coreDataStack?.saveContext()
            }
        }
    }
    
    @IBOutlet weak var importBarButton: UIBarButtonItem!
    
    // Function that imports the cards using Https on a backgound thread
    @IBAction func importCards(_ sender: UIBarButtonItem) {
        var url: String
        importBarButton.isEnabled = false
        if let urlText = set?.importURL {
            url = urlText
        } else {
            url = ""
        }
    
        let jsonURL = URL(string: url)!
        let sessionConfiguration = URLSessionConfiguration.ephemeral
        let session = URLSession(configuration: sessionConfiguration)
        var flashCards : [[String:Any]]?
        
        //Background task
        let task = session.dataTask(with: jsonURL, completionHandler: { dataOptional, response, error in
            // Enable the button and reload the table view when the operation finishes.
            //
            defer {
                DispatchQueue.main.async {
                    self.importBarButton.isEnabled = true
                    self.reloadData(randomBool: false, showBool: true)
                    self.tableView.reloadData()
                }
            }
            
            // If we don't get data back, alert the user.
            //
            guard let data = dataOptional else {
                let description = NSLocalizedString("Could not get data from the remote server", comment: "Failed to connect to server")
                self.presentError(description, code: .serverConnectionFailed, underlyingError: error)
                print("Error no data")
                return
            }
            
            // If we get data but can't unpack it as JSON, alert the user.
            //
            do {
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any],
                    let cards = jsonArray["cards"] as? [[String:Any]] {
                        flashCards = cards
                }
                //Import into core data
                if let flash = flashCards {
                    self.importJSONToCoreData(flash)
                }
            }
            catch {
                let description = NSLocalizedString("Could not analyze flashcards data", comment: "Failed to unpack JSON")
                self.presentError(description, code: .extractingJSONFailed, underlyingError: error)
                return
            }
        })
        task.resume()
    }
    
    // MARK: - View Life Cycle  UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        if let name = set?.name {
            title = name
        }
        //TODO: Check into reloadData and .reloadData
        reloadData(randomBool: false, showBool: true)
        tableView.reloadData()
        // print("CardsViewController.viewDidLoad()")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        //TODO: Check into reloadData and .reloadData
        reloadData(randomBool: false, showBool: true)
        tableView.reloadData()
        //print("CardsViewController.viewWillAppear()")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueEditCard {
            let editCardViewController = segue.destination as! CardViewController
            editCardViewController.set = set
            editCardViewController.card = fetchResultsController?.object(at: indexPathSeque!)
            editCardViewController.coreDataStack = coreDataStack
            editCardViewController.cards = fetchResultsController!.fetchedObjects
            editCardViewController.indexCards = indexPathSeque!.row
            //, let indexPath = tableView.indexPathForSelectedRow
        } else if segue.identifier == segueAddNewCard {
            // pass set to add card to
            let addCardViewController = segue.destination as! CardViewController
            addCardViewController.set = set
            addCardViewController.coreDataStack = coreDataStack
        } else if segue.identifier == seguePageViewController {
            let countCards = fetchResultsController?.fetchedObjects?.count ?? 0
            let countCardsNoShow = set?.countShow ?? 0
            //No cards dont start flash cards
            if (countCards > 0) && countCardsNoShow < countCards {
                let pageViewController = segue.destination as! PageViewController
                // If deck should be shuffled and any cards are marked not to show
                if set?.randomize == true {
                    let  count: Int = fetchResultsController?.fetchedObjects?.count ?? 0
                    if let cards = fetchResultsController?.fetchedObjects {
                        for i in 0 ..< count {
                            cards[i].randomsort = drand48()
                        }
                    }
                    coreDataStack?.saveContext()
                    //Reload fetchResultsController sorted randomly and with show = true
                    reloadData(randomBool: true, showBool: false)
                } else {
                    reloadData(randomBool: false, showBool: false)
                }
                tableView.reloadData()
                pageViewController.titleString = set?.name
                pageViewController.cards = fetchResultsController?.fetchedObjects
                pageViewController.coreDataStack = coreDataStack
            
            }
        } else if segue.identifier == segueExport {
            let exportViewController = segue.destination as! ExportViewController
            exportViewController.exportedSetCVS = exportCVS
            exportViewController.exportedSetJSON = exportJSON
        }
            // Unknow segue.
        else {
            //throw error
            print("Unknown segue")
        }
    }
    // MARK: Functions
    
    // Export CSV format
    // TODO:  easier way and have a extra line space between the strings output
    fileprivate func ExportData() -> String {
        var tempString: String = ""
        let exportFilePath = NSTemporaryDirectory() + "export.csv"
        //print("the file path is \(exportFilePath)")
        let exportFileURL = URL(fileURLWithPath: exportFilePath)
        FileManager.default.createFile(atPath: exportFilePath, contents: Data(), attributes: nil)
        
        let fileHandle:FileHandle?
        do {
            fileHandle = try FileHandle(forWritingTo: exportFileURL)
        } catch let error as NSError {
            print("ERROR \(error.localizedDescription)")
            fileHandle = nil
        }
        //Write to temp file as test. To be used latter
        if let fileHandle = fileHandle {
            
            if let cards = fetchResultsController?.fetchedObjects {
                
                for card in cards {
                    tempString = tempString + card.csv()
                }
                
                for card in cards {
                    fileHandle.seekToEndOfFile()
                    //print(card.csv())
                    guard let csvDataCard = card.csv().data(using: .utf8, allowLossyConversion: false) else {
                        continue
                    }
                    fileHandle.write(csvDataCard)
                }
                fileHandle.closeFile()
                do {
                    exportCVS = try String(contentsOf: exportFileURL)
                    print(exportCVS ?? "Errror or no data found for export")
                } catch let error as NSError {
                    print ("Error \(error.localizedDescription)")
                }
            }
        }
        return tempString
    }
    
    // Function to export the cards to JSON.
    fileprivate func exportCardsToJson() ->String {
        let headerJson = "{ \"cards\": [\n"
        let beginBracket = "{\n"
        let endBracket = "\n},\n"
        let endBracketnoComma = "\n}\n"
        let tailJson = "]\n}\n"
        let front = "    \"front\":"
        let back =  "    \"back\":"
        let doubleQuote = "\",\n"
        let doubleQuoteNoNewLine = "\""
        var stringJson = headerJson
        var cardFront = ""
        var cardBack = ""
               
        if let cards = fetchResultsController?.fetchedObjects {
            stringJson = headerJson
            
            if (cards.count == 0 ) {
                return ""
            }
            let countCards = cards.count
            for  i in 0 ... countCards - 1 {
                cardFront = cards[i].front ?? ""
                cardBack = cards[i].back ?? ""
                cardFront = cardFront.replacingOccurrences(of: "\"", with: "\\\"")
                cardFront = cardFront.replacingOccurrences(of: "\n", with: "\\n")
                cardBack = cardBack.replacingOccurrences(of: "\"", with: "\\\"")
                cardBack = cardBack.replacingOccurrences(of: "\n", with: "\\n")
                stringJson = stringJson + beginBracket
                stringJson = stringJson + front + doubleQuoteNoNewLine + cardFront + doubleQuote
                
                if (i == countCards - 1 ) {
                    stringJson = stringJson + back  + doubleQuoteNoNewLine + cardBack + doubleQuoteNoNewLine + endBracketnoComma
                } else {
                    stringJson = stringJson + back  + doubleQuoteNoNewLine + cardBack + doubleQuoteNoNewLine + endBracket
                }
            }
            stringJson = stringJson + tailJson
        }
        print(stringJson)
        return stringJson
    }
    
    fileprivate func importJSONToCoreData (_ flashCards: [[String:Any]]) {
        for card in flashCards {
            if let front = card["front"] as? String, let back = card["back"] as? String  {
                let newCard = Card(context: (coreDataStack?.managedContext)!)
                newCard.front = front
                newCard.back = back
                newCard.show = true
                newCard.date = NSDate()
                set?.addToCards(newCard)
             }
         }
        
        do {
            try coreDataStack?.managedContext.save()
        } catch {
            let description = NSLocalizedString("Could not process data and add to CoreData", comment: "Failed to import to CoreData")
            self.presentError(description, code: .commitingDataCoreDataFailed, underlyingError: error)
            return
        }
     }
    
    // code from Apples Earthquakes demo
    fileprivate func presentError(_ description: String, code: CardsViewControllerErrorCodes, underlyingError error: Error?) {
        
        var userInfo: [String: AnyObject] = [
            NSLocalizedDescriptionKey: description as AnyObject
        ]
        
        if let error = error as NSError? {
            userInfo[NSUnderlyingErrorKey] = error
        }
        
        let creationError = NSError(domain: AppDelegate.FlashCardSwiftErrorDomain, code: code.rawValue, userInfo: userInfo)
        
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Error message", message: creationError.localizedDescription , preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .default)
            alert.addAction(cancelAction)
            self.present(alert, animated: true )
        }
    }
    
    // Reloads the data by fetching data
    // TODO:  ReloadData is overkill
    private func reloadData(randomBool boolRandom: Bool, showBool boolShow: Bool) {
        let fetchRequest: NSFetchRequest<Card> = Card.fetchRequest()
        if boolRandom == false {
            cardSortDescriptor = NSSortDescriptor(key: #keyPath(Card.date), ascending: true)
        } else {
            cardSortDescriptor = NSSortDescriptor(key: #keyPath(Card.randomsort), ascending: true)
        }
        
        fetchRequest.sortDescriptors = [cardSortDescriptor!]
        cardNamePredicate = NSPredicate(format: "%K == %@",#keyPath(Card.set.name), (set?.name)!)
        if boolShow == true {
            fetchRequest.predicate = cardNamePredicate
        }else {
            cardShowPredicate = NSPredicate(format: "%K == %@",#keyPath(Card.show), NSNumber(booleanLiteral: true))
            cardPredicates = NSCompoundPredicate(andPredicateWithSubpredicates: [cardNamePredicate!, cardShowPredicate!])
            fetchRequest.predicate = cardPredicates
        }
        
        fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: (coreDataStack?.storeContainer.viewContext)!, sectionNameKeyPath: nil, cacheName: nil)
        fetchResultsController?.delegate = self
        
        do {
            try fetchResultsController?.performFetch()
        } catch let error as NSError {
            print("Fetching error \(error), \(error.userInfo)")
        }
    }
    
    func configure( _ cell: CardTableViewCell, at indexPath: IndexPath) {
        //Fetch Set
        let card = fetchResultsController?.object(at: indexPath)
        cell.frontCard.text = card?.front
        cell.backCard.text = card?.back
        if (card?.show)! {
            cell.showCard.text = "TRUE"
        } else {
            cell.showCard.text = "FALSE"
        }
    }
  
    // MARK: NSFetchResultsControllerDelegate
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
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
            if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) as? CardTableViewCell {
                configure(cell, at: indexPath)
            }
            break;
            
        default:
            print("default")
        }
    }
    
    
    // MARK: UITableViewDataSource
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let cards = fetchResultsController?.fetchedObjects else {
            return 1
        }
        return cards.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CardTableViewCell.reuseIdentifier, for: indexPath) as? CardTableViewCell else {
            fatalError("Unexpected Index path")
        }
        guard let card = fetchResultsController?.object(at: indexPath) else {
            return cell
        }
        //cell appearance
        // TODO: Improve the cell visibility
        cell.layer.borderColor = UIColor.lightGray.cgColor
        cell.layer.borderWidth = 1
        //        cell.layer.cornerRadius = 8
        //        cell.clipsToBounds = true
        //        cell.backgroundColor = UIColor.lightGray
        
        cell.frontCard.text = card.front
        cell.backCard.text = card.back
        if card.show {
            cell.showCard.text = "TRUE"
        } else {
            cell.showCard.text = "FALSE"
        }
        return cell
    }
    
    // MARK: UTTableViewDelegate
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .default, title: "Delete"){ ( action, indexPath) in
            let card = self.fetchResultsController?.object(at: indexPath)
            self.set?.removeFromCards(card!)
            self.coreDataStack?.saveContext()
        }
        delete.backgroundColor = UIColor.red
        
        let edit = UITableViewRowAction(style: .default, title: "Edit") { (action, indexPath) in

            self.indexPathSeque = indexPath
            self.performSegue(withIdentifier: self.segueEditCard, sender: self)
        }
        edit.backgroundColor = UIColor.green
        return [edit, delete]
    }
}
