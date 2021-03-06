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
        tableView.tableFooterView = UIView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let userDefaults = UserDefaults.standard
        let locateQuality = userDefaults.integer(forKey: Prefix.keyLocateQuality)
        switch locateQuality {
        case 0:
            locateQualityLabel.text = Prefix.strLocateQualityHigh
        case 1:
            locateQualityLabel.text = Prefix.strLocateQualityNormal
        case 2:
            locateQualityLabel.text = Prefix.strLocateQualityLow
        default:
            locateQualityLabel.text = Prefix.strLocateQualityNormal
        }
    }

    @IBAction func didTapCloseButon(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func returnSettingViewForSegue(_ segue: UIStoryboardSegue) {
    }
}
