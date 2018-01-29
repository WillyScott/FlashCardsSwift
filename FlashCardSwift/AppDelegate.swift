//
//  AppDelegate.swift
//  FlashCardSwift
//
//  Created by Scott Gromme on 2/24/17.
//
//

import UIKit
import CoreData

// data the gets imported first time app is installed and started
extension String {
    static var fileNameIntroductionsSwift:String { return "introductionSwiftCard" }
    static var fileNameSwiftKeywords:String { return "Swift_KeywordsV3_0_1"  }
    static var jsonExtension:String { return "json" }
    static var fileNameIntroductionsSwiftPath:String { return "https://raw.githubusercontent.com/WillyScott/FlashCardsData/master/introductionSwiftCard.json"}
    static var fileNameSwiftKeywordsPath:String { return "https://raw.githubusercontent.com/WillyScott/FlashCardsData/master/Swift_KeywordsV3_0_1.json"}
    static var fileNameIntroductionsSwiftDescription:String { return "Introduction to SwiftCards" }
    static var fileNameSwiftKeywordDescription:String { return "Swift keywords Version 3"}
    static var fileNameInitialLoad:String { return "InitialDataLoaded"}
    static var plistExtension:String { return "plist"}
}


@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    static let FlashCardSwiftErrorDomain = "FlashCardSwiftErrorDomain"
    lazy var coreDataStack = CoreDataStack(modelName: "FlashCardSwift")
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        guard let navController = window?.rootViewController as? UINavigationController, let viewController = navController.topViewController as? ViewController else {
            return true
        }
        viewController.coreDataStack = coreDataStack
        
        //Load preloaded data is app has no CoreData
        if !checkForData() {
            preloadJson()
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        coreDataStack.saveContext()
        
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    //
    fileprivate func checkForData () -> Bool {
        let setRequest:NSFetchRequest<Set> = Set.fetchRequest()
        print("AppDelegate.checkForData()")
        do{
            let results = try coreDataStack.managedContext.fetch(setRequest)
            if results.count == 0 {
                return false
            }else {
                // For upgrades of FlashCardSwift the creation of a new field section
                // causes a error problem with the first screen sorting on section field
                for set in results {
                    if let _ = set.section {
                        
                    } else {
                        set.section = ""
                    }
                }
                coreDataStack.saveContext()
            }

        } catch let error as NSError {
            print("Fetch error: \(error) description \(error.userInfo)")
            return true
        }
        return true
    }
    
    // Function that checks to see if the initial load of data has already
    fileprivate func readPlist() -> Bool {
        struct Status: Codable {
            var dataLoaded: Bool
        }
        
        var settings: Status?
        let settingstoWrite = Status(dataLoaded:true)
        let settingsURL = Bundle.main.url(forResource: String.fileNameInitialLoad, withExtension: String.plistExtension)
        
        do {
            
            let   data = try Data(contentsOf: settingsURL!)
            let decoder = PropertyListDecoder()
            //settings = try decoder.decode(settings, from: data)
            settings = try decoder.decode(Status.self, from: data)
            if (settings?.dataLoaded == false) {
                print("AppDelegate.readPlist() false")
                // set the boolean value to true so the initial files won't be loaded
                let encoder = PropertyListEncoder()
                encoder.outputFormat = .xml
                do {
                    print("setting to true")
                    let dataWritten = try encoder.encode(settingstoWrite)
                    try dataWritten.write(to: settingsURL!)
                } catch let error {
                    print("Error writting to plist: " + error.localizedDescription)
                }
                return true
            } else {
                print("AppDelegate.readPlist() true")
                return false
            }
   
        } catch let error {
                print("Error reading/decoding the plist file: " + error.localizedDescription )
                return true
        }
    }
    
    
    // Loads Json data in the bundle, this way a new app comes with data(doesnt have to use network
    // to load), the data exists on the github acccount.
    fileprivate func preloadJson() {
        var flashCards : [[String:Any]]?
        let paths = [(String.fileNameIntroductionsSwift,String.fileNameIntroductionsSwiftPath, String.fileNameIntroductionsSwiftDescription ), (String.fileNameSwiftKeywords,String.fileNameSwiftKeywordsPath, String.fileNameSwiftKeywordDescription)]
        for path in paths {
            if let jsonFileURL = Bundle.main.url(forResource: path.0, withExtension: String.jsonExtension) {
                
                do {
                    let data = try Data(contentsOf: jsonFileURL, options: .alwaysMapped)
                    //let jsonObj = JSONSerializer.toJson(data)
                    if let jsonData = try JSONSerialization.jsonObject(with:data, options:JSONSerialization.ReadingOptions(rawValue:0)) as? [String:Any], let cards = jsonData["cards"] as? [[String:Any]] {
                        flashCards = cards
                    }
                } catch let error {
                    print(error.localizedDescription)
                }
                //Create sets to store introduction and swift keywords
                let setIntroduction = Set(context: coreDataStack.managedContext)
                setIntroduction.name = path.0
                setIntroduction.descriptionSet = path.2
                setIntroduction.date = NSDate()
                setIntroduction.importURL = path.1
                setIntroduction.randomize = false
                setIntroduction.section = ""
                // add
                for card in flashCards! {
                    if let front = card["front"] as? String, let back = card["back"] as? String  {
                        let newCard = Card(context: coreDataStack.managedContext)
                        newCard.front = front
                        newCard.back = back
                        newCard.show = true
                        newCard.date = NSDate()
                        setIntroduction.addToCards(newCard)
                    }
                }
                
                do {
                    try coreDataStack.managedContext.save()
                    
                } catch let error as NSError {
                    print("Save error  \(error) description \(error.userInfo)")
                }
                
            }
        }
    }
}
