//
//  PageViewController.swift
//  Pogger
//
//  Created by Taiju Aoki on 2016/10/30.
//  Copyright © 2016年 Taiju Aoki. All rights reserved.
//

import UIKit

class PageViewController: UIPageViewController, UIPageViewControllerDataSource {

    override func viewDidLoad() {
        super.viewDidLoad()
        changeViewController(.records)
        self.dataSource = self
        self.view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }

    private func changeViewController(_ listType: ListType) {
        let direction: UIPageViewControllerNavigationDirection
        switch listType {
        case .records:
            direction = .reverse
        case .favorites:
            direction = .forward
        }
        self.setViewControllers([getListViewController(listType)], direction: direction, animated: true, completion: nil)
    }

    private func getListViewController(_ listType: ListType) -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        switch listType {
        case .records:
            return storyboard.instantiateViewController(withIdentifier: "Record") as! RecordViewController
        case .favorites:
            return storyboard.instantiateViewController(withIdentifier: "Favorite") as! FavoriteListViewController
        }
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if viewController.isKind(of: RecordViewController.self) {
            return getListViewController(.favorites)
        } else {
            return nil
        }
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if viewController.isKind(of: FavoriteListViewController.self) {
            return getListViewController(.records)
        } else {
            return nil
        }
    }

    @IBAction func didSelectSegmentedControl(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            changeViewController(.records)
        case 1:
            changeViewController(.favorites)
        default:
            break
        }
    }
}
