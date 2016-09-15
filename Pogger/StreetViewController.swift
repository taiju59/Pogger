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
            panoView.move(toPanoramaID: panoramaID!)
        }
        if coordinater != nil {
            panoView.moveNearCoordinate(coordinater!)
        }
        panoView.delegate = self
        self.view.insertSubview(panoView, at: 0)
    }

    func panoramaView(_ panoramaView: GMSPanoramaView, didTap point: CGPoint) {
        UIView.animate(
            withDuration: 0.1,
            animations: {() -> Void  in
                self.headerView.alpha = self.headerView.alpha == 0 ? 1:0
        })
    }
}
