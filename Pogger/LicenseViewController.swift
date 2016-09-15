//
//  LicenseViewController.swift
//  Pogger
//
//  Created by Taiju Aoki on 2016/05/19.
//  Copyright © 2016年 Taiju Aoki. All rights reserved.
//

import UIKit

class LicenseViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        textView.decelerationRate = UIScrollViewDecelerationRateNormal

        let getTxtQueue = DispatchQueue(label: "getTxtQueue", attributes: [])
        getTxtQueue.async {
            let filePath = Bundle.main.path(forResource: "LICENSE", ofType: "txt")
            let licenseStr = try! String(contentsOfFile: filePath!, encoding: String.Encoding.utf8)
            DispatchQueue.main.async {
                self.textView.text = licenseStr
            }
        }
    }
}
