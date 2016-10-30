//
//  RecordViewController.swift
//  Pogger
//
//  Created by Taiju Aoki on 2016/04/17.
//  Copyright © 2016年 Taiju Aoki. All rights reserved.
//

import UIKit

class RecordViewController: ListViewController {

    @IBOutlet weak var tableView: UITableView!

    override var viaTableView: UITableView! {
        return tableView
    }

    override var listType: ListType! {
        return .records
    }

    //MARK: - Action
    @IBAction override func didLongSelect(_ sender: UILongPressGestureRecognizer) {
        super.didLongSelect(sender)
    }
}
