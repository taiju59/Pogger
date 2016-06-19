//
//  LocateQualityViewController.swift
//  Pogger
//
//  Created by Taiju Aoki on 2016/05/19.
//  Copyright © 2016年 Taiju Aoki. All rights reserved.
//

import UIKit

class LocateQualityViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView(frame: CGRectZero)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let locateQuality = userDefaults.integerForKey(Prefix.KEY_LOCATE_QUALITY)
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: locateQuality, inSection: 0))
        cell?.accessoryType = .Checkmark
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        let locateQuality: Int
        switch indexPath.row {
        case 0:
            locateQuality = 0
        case 1:
            locateQuality = 1
        case 2:
            locateQuality = 2
        default:
            locateQuality = 0
        }
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setInteger(locateQuality, forKey: Prefix.KEY_LOCATE_QUALITY)
        userDefaults.synchronize()
        
        LocationModel.sharedInstance.changeDesiredAccuracy(locateQuality)
    }

}