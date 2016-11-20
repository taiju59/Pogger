//
//  VisitMonitoring.swift
//  Pogger
//
//  Created by Taiju Aoki on 2016/11/20.
//  Copyright © 2016年 Taiju Aoki. All rights reserved.
//

import CoreLocation

protocol VisitMonitoringDelegate: class {
    func visitMonitoring(_ visitMonitoring: VisitMonitoring, manager: CLLocationManager, didVisit visit: CLVisit)
}

class VisitMonitoring: NSObject, CLLocationManagerDelegate {

    private var manager = CLLocationManager()
    static let sharedInstance = VisitMonitoring()

    weak var delegate: VisitMonitoringDelegate?

    override private init() {
        super.init()
        manager.delegate = self
        manager.requestAlwaysAuthorization()
    }

    func start() {
        manager.startMonitoringVisits()
    }

    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        delegate?.visitMonitoring(self, manager: manager, didVisit: visit)
    }
}
