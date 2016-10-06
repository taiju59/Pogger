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

class MapViewController: UIViewController, SelectTermViewControllerDelegate {
    @IBOutlet weak var MapView: MKMapView!
    @IBOutlet weak var selectTermButton: UIBarButtonItem!

    private var receiveTermValue = 7

    override func viewDidLoad() {
        super.viewDidLoad()
        selectTermButton.title = "1週間"
        setMap()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setPin()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == "toSelectTermView" {
            let vc = segue.destination as! SelectTermViewController
            vc.delegate = self
        }
    }

    func selectTermViewController(_ selectTermViewController: SelectTermViewController, selectTerm value: Int, selectTerm title: String?) {
        receiveTermValue = value
        selectTermButton.title = title
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.default
    }

    func setPin() {
        let now = Date()
        let realm = try! Realm()
        let dispMinuteMin = 10
        let timeInterval = -60 * 60 * 24  * receiveTermValue
        let allPoints = realm.objects(Point.self)
        let term = Date(timeInterval: TimeInterval(timeInterval), since: now)
        let predicate = NSPredicate(format: "stayMin >= %d AND startDate >= %@", dispMinuteMin, term as CVarArg)
        let points = allPoints.filter(predicate)

        //地図にピンを立てる。
        for point in points {
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
        let center = CLLocationCoordinate2DMake(latitude, longitude)

        //表示範囲
        let span = MKCoordinateSpanMake(0.1, 0.1)

        //中心座標と表示範囲をマップに登録する。
        let region = MKCoordinateRegionMake(center, span)
        MapView.setRegion(region, animated: true)
    }
}

