//
//  SettingViewController.swift
//  Pogger
//
//  Created by Taiju Aoki on 2016/05/18.
//  Copyright © 2016年 Taiju Aoki. All rights reserved.
//

import UIKit

class SettingViewController: UITableViewController {
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var locateQualityLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "設定"
        tableView.tableFooterView = UIView(frame: CGRectZero)
        
        closeButton.setTitle(Prefix.ICON_X, forState: .Normal)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let locateQuality = userDefaults.integerForKey(Prefix.KEY_LOCATE_QUALITY)
        switch locateQuality {
        case 0:
            locateQualityLabel.text = Prefix.STR_LOCATE_QUALITY_HIGH
        case 1:
            locateQualityLabel.text = Prefix.STR_LOCATE_QUALITY_NORMAL
        case 2:
            locateQualityLabel.text = Prefix.STR_LOCATE_QUALITY_LOW
        default:
            locateQualityLabel.text = Prefix.STR_LOCATE_QUALITY_NORMAL
        }
    }
    
    @IBAction func returnSettingViewForSegue(segue: UIStoryboardSegue) {
        
    }
    
}
