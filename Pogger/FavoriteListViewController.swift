//
//  FavoriteListViewController.swift
//  Pogger
//
//  Created by natsuyama on 2016/09/29.
//  Copyright © 2016年 Taiju Aoki. All rights reserved.
//

import UIKit

class FavoriteListViewController: ListViewController {

    @IBOutlet weak var tableView: UITableView!

    override var viaTableView: UITableView! {
        return tableView
    }

    override var listType: ListType! {
        return .favorites
    }

    //MARK: - Action
    @IBAction override func didLongSelect(_ sender: UILongPressGestureRecognizer) {
        super.didLongSelect(sender)
    }
}
