//
//  LocateQualityViewController.swift
//  Pogger
//
//  Created by Taiju Aoki on 2016/05/19.
//  Copyright © 2016年 Taiju Aoki. All rights reserved.
//

import UIKit

enum LocationQuality: Int {
    case High
    case Normal
    case Low
}

class LocateQualityViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let locateQuality = userDefaults.integerForKey(Prefix.keyLocateQuality)
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: locateQuality, inSection: 0))
        cell?.accessoryType = .Checkmark
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        let locationQuality: LocationQuality
        switch indexPath.row {
        case 0:
            locationQuality = .High
        case 1:
            locationQuality = .Normal
        case 2:
            locationQuality = .Low
        default:
            locationQuality = .Normal
        }
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setInteger(locationQuality.rawValue, forKey: Prefix.keyLocateQuality)
        userDefaults.synchronize()

        LocationModel.sharedInstance.setAccuracy(locationQuality)
    }

}
