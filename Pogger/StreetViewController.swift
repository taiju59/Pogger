//
//  StreetViewController.swift
//  Pogger
//
//  Created by Taiju Aoki on 2016/04/19.
//  Copyright © 2016年 Taiju Aoki. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation

class StreetViewController: UIViewController, GMSPanoramaViewDelegate {
    
    @IBOutlet weak var headerView: UIView!
    
    var panoramaID: String?
    var coordinater: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let panoView = GMSPanoramaView(frame: self.view.frame)
        if panoramaID != nil {
            panoView.moveToPanoramaID(panoramaID!)
        }
        if coordinater != nil {
            panoView.moveNearCoordinate(coordinater!)
        }
        panoView.delegate = self
        self.view.insertSubview(panoView, atIndex: 0)
    }
    
    func panoramaView(panoramaView: GMSPanoramaView, didTap point: CGPoint) {
        UIView.animateWithDuration(
            0.1,
            animations: {() -> Void  in
                self.headerView.alpha = self.headerView.alpha == 0 ? 1:0
        })
    }
    
//    override func canPerformUnwindSegueAction(action: Selector, fromViewController: UIViewController, withSender sender: AnyObject) -> Bool {
//        //ここに戻る前の処理を記述
//        print("return ListView")
//        return true
//    }
    
}