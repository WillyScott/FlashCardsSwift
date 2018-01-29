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
        if let name = titleString {
            title = name
        }
        // If a empty card set is sent or empty card set because all the cards are marked as known just return
        if let _ = cards  {
            dataSource = self
            setViewControllers([initialViewController], direction: .forward, animated: false, completion: nil)
        } else {
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
}

// MARK: - UIPageViewControlerDataSource
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
   
        // allow the user to swipe left and go from card 1 to lastcard and vs versa
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

