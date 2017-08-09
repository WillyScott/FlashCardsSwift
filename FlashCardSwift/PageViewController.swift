//
//  PageViewController.swift
//  FlashCardSwift
//
//  Created by Scott Gromme on 4/18/17.
// 
//

import UIKit

class PageViewController: UIPageViewController {
    
    var cards: [Card]!
    var coreDataStack: CoreDataStack!
    var titleString:String?
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //view.gestureRecognizers
//        let recognizers = gestureRecognizers
//        for i in 0 ..<  recognizers.count {
//            print("recognizers are set to \(recognizers[i].cancelsTouchesInView)")
//            recognizers[i].cancelsTouchesInView = false
//        }
//        print("PageViewController")
//        print("count of gestureRecognizer is \(recognizers.count)")
        //If cards is not empty
        if let name = titleString {
            title = name
        }
        if let _ = cards  {
            dataSource = self
            setViewControllers([initialViewController], direction: .forward, animated: false, completion: nil)
        } else {
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
}

// MARK: -
extension PageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        if let viewController = viewController as? FlashCardFrontViewController, let pageIndex = viewController.pageIndex{
            
            if pageIndex > 0 {
                return viewControllerAtIndex(pageIndex - 1)
              } else if pageIndex == 0 {
                return viewControllerAtIndex(cards.count - 1)
                
            }
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        
        if let viewController = viewController as? FlashCardFrontViewController, let pageIndex = viewController.pageIndex {
            if pageIndex < cards.count - 1 {
                return viewControllerAtIndex(pageIndex + 1)
            } else if pageIndex == cards.count - 1 {
                return viewControllerAtIndex(0)
            }
        }
        return nil
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return cards.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
}

extension PageViewController: ViewControllerProvider {
    
    var initialViewController: UIViewController {
        return viewControllerAtIndex(0)!
    }
    
    func viewControllerAtIndex(_ index: Int) -> UIViewController? {
        
        if let cardViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FlashCardFrontViewController") as? FlashCardFrontViewController {
            
            cardViewController.pageIndex = index
            cardViewController.card = cards[index]
            cardViewController.count = cards.count
            cardViewController.coreDataStack = coreDataStack
            return cardViewController
        }
        
        return nil
    }
    
    
    
}

