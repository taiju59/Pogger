//
//  MapViewController.swift
//  Pogger
//
//  Created by natsuyama on 2016/10/03.
//  Copyright © 2016年 Taiju Aoki. All rights reserved.
//

import UIKit
import MapKit
import RealmSwift
import CoreLocation


class MapViewController: UIViewController, CLLocationManagerDelegate{
    @IBOutlet weak var MapView: MKMapView!

    let realm = try! Realm()
    var myLocationManager: CLLocationManager!

    override func viewDidLoad() {
        super.viewDidLoad()

        let status = CLLocationManager.authorizationStatus()
        if status == CLAuthorizationStatus.restricted || status == CLAuthorizationStatus.denied {
            return
        }

        myLocationManager = CLLocationManager()
        myLocationManager.delegate = self

        if status == CLAuthorizationStatus.notDetermined {
            myLocationManager.requestWhenInUseAuthorization()
        }

        if !CLLocationManager.locationServicesEnabled() {
            return
        }
        myLocationManager.desiredAccuracy = kCLLocationAccuracyBest
        myLocationManager.distanceFilter = kCLDistanceFilterNone

        setMap()
        setPin()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setPin() {
        //listviewcontrollerに表示されているのと同じ
        let dispMinuteMin = 10
        let allPoints = realm.objects(Point.self)
        let lastPointDate = allPoints[0].startDate!
        let predicate = NSPredicate(format: "stayMin >= %d OR startDate = %@",
                                    dispMinuteMin, lastPointDate as CVarArg)
        let points = allPoints.filter(predicate)

        //地図にピンを立てる。
        for point in points {
            //print(point.latitude)
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2DMake(point.latitude, point.longitude)
            MapView.addAnnotation(annotation)
        }
    }

    func setMap() {
        //sharedInstanceによる値渡し(経度緯度)
        let latitude = LocationService.sharedInstance.newestLocation.coordinate.latitude
        let longitude = LocationService.sharedInstance.newestLocation.coordinate.longitude

        //中心座標
        let center = CLLocationCoordinate2DMake(latitude, longitude
        )

        //表示範囲
        let span = MKCoordinateSpanMake(0.1, 0.1)

        //中心座標と表示範囲をマップに登録する。
        let region = MKCoordinateRegionMake(center, span)
        MapView.setRegion(region, animated:true)
    }
}

