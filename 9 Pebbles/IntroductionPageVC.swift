//
//  IntroductionPageVC.swift
//  9 Pebbles
//
//  Created by Ashis Laha on 15/11/16.
//  Copyright © 2016 Ashis Laha. All rights reserved.
//

import UIKit

struct IntroductionConstants {
    static let NumberOfPages = 5
    static let text1 = "Intially both player have 9 pebbles. Use your pebble in empty place to create a STRAIGHT LINE either Horizontally or Vertically."
    static let text2 = "On click of 'Options', you can play with 'Computer' or 'Offline' in 2 players locally. User can chat with other online users also."
    static let text3 = "In the Right Section, you will get the update for 'Remaining Pebbles' and 'Claim Pebbles' count values."
    static let text4 = "When a STRAIGHT LINE is created you must claim a pebble from opposition which is not belonging to a STRAIGHT LINE."
    static let text5 = "Once all 9 pebbles are placed, Single movement starts. When you claim more than 7 pebbles, YOU WIN !!!"
}


class IntroductionPageVC: UIPageViewController {
    
    var orderedVCs : [UIViewController] = []
    
    func getViewController(index : Int) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "page\(index)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        for i in 1...IntroductionConstants.NumberOfPages { orderedVCs.append(getViewController(index: i))}
        
        // intialize the page view controller
        if let firstVC = orderedVCs.first {
            setViewControllers([firstVC], direction: .forward, animated: true, completion: nil)
        }
    }
    
    //MARK:- Orientation
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return .portrait
        } else if UIDevice.current.userInterfaceIdiom == .phone {
            return .landscape
        } else {
            return .landscape
        }
    }
    override var shouldAutorotate: Bool {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return false
        } else if UIDevice.current.userInterfaceIdiom == .phone {
            return true
        } else {
            return true
        }
    }
}

//MARK:- Datasource

extension IntroductionPageVC : UIPageViewControllerDataSource {
    
    // after page
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let index = orderedVCs.index(of: viewController) else { return nil }
        let afterIndex = index+1
        guard afterIndex != orderedVCs.count else { return orderedVCs.first }
        guard afterIndex < orderedVCs.count else { return nil }
        return orderedVCs[afterIndex]
    }
    
    // before page
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let index = orderedVCs.index(of: viewController) else { return nil }
        let beforeIndex = index-1
        guard beforeIndex >= 0 else { return orderedVCs.last }
        guard beforeIndex < orderedVCs.count else { return nil }
        return orderedVCs[beforeIndex]
    }
    
    // This is used for Dots represenation
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return orderedVCs.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
}

