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
        
        let getTxtQueue = dispatch_queue_create("getTxtQueue", nil)
        dispatch_async(getTxtQueue) {
            let filePath = NSBundle.mainBundle().pathForResource("LICENSE", ofType: "txt")!
            let licenseStr = try! String(contentsOfFile: filePath, encoding: NSUTF8StringEncoding)
            dispatch_async(dispatch_get_main_queue()) {
                self.textView.text = licenseStr
            }
        }
    }
    
}