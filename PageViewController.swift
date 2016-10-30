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
        self.setViewControllers([getListViewController(.records)], direction: .forward, animated: true, completion: nil)
        self.dataSource = self
        self.view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
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
}
