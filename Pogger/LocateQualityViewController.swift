//
//  LocateQualityViewController.swift
//  Pogger
//
//  Created by Taiju Aoki on 2016/05/19.
//  Copyright © 2016年 Taiju Aoki. All rights reserved.
//

import UIKit

enum LocationQuality: Int {
    case high
    case normal
    case low
}

class LocateQualityViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let userDefaults = UserDefaults.standard
        let locateQuality = userDefaults.integer(forKey: Prefix.keyLocateQuality)
        let cell = tableView.cellForRow(at: IndexPath(row: locateQuality, section: 0))
        cell?.accessoryType = .checkmark
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let locationQuality: LocationQuality
        switch (indexPath as IndexPath).row {
        case 0:
            locationQuality = .high
        case 1:
            locationQuality = .normal
        case 2:
            locationQuality = .low
        default:
            locationQuality = .normal
        }
        let userDefaults = UserDefaults.standard
        userDefaults.set(locationQuality.rawValue, forKey: Prefix.keyLocateQuality)
        userDefaults.synchronize()

        StandardLocation.sharedInstance.setAccuracy(locationQuality)
    }

}
