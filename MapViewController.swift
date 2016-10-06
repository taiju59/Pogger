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

class MapViewController: UIViewController, SelectTermViewControllerDelegate, MKMapViewDelegate {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var selectTermButton: UIBarButtonItem!

    private var receiveTermValue = 7

    override func viewDidLoad() {
        super.viewDidLoad()
        selectTermButton.title = "1週間"
        setMap()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == "toSelectTermView" {
            let vc = segue.destination as! SelectTermViewController
            vc.delegate = self
        }
    }

    func selectTermViewController(_ selectTermViewController: SelectTermViewController, selectTerm value: Int, title: String?) {
        receiveTermValue = value
        selectTermButton.title = title
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
        mapView.setRegion(region, animated: true)
    }

    //Mapが更新されるたびに呼び出される
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let mRect = mapView.visibleMapRect
        //Map画面上の中心座標
        let topMapPoint = MKMapPointMake(MKMapRectGetMidX(mRect), MKMapRectGetMinY(mRect))
        //Map画面下の中心座表
        let bottomMapPoint = MKMapPointMake(MKMapRectGetMidX(mRect), MKMapRectGetMaxY(mRect))
        let radius = MKMetersBetweenMapPoints(topMapPoint, bottomMapPoint) / 2
        setPin(radius: radius)
    }

    private func setPin(radius: Double) {
        let now = Date()
        let realm = try! Realm()
        let dispMinuteMin = 10
        let timeInterval = -60 * 60 * 24  * receiveTermValue
        let allPoints = realm.objects(Point.self)
        let term = Date(timeInterval: TimeInterval(timeInterval), since: now)
        let predicate = NSPredicate(format: "stayMin >= %d AND startDate >= %@", dispMinuteMin, term as CVarArg)
        let points = allPoints.filter(predicate)
        //地図上のピンを削除
        mapView.removeAnnotations(mapView.annotations)
        //地図にピンを立てる。
        for point in points {
            //中心座標取得
            let centerPoint = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
            //一つ一つのピンの座標を取得
            let pinPoint = CLLocation(latitude: point.latitude, longitude: point.longitude)
            let distance = centerPoint.distance(from: pinPoint)
            let annotation = MKPointAnnotation()
            if radius > distance {
                annotation.coordinate = CLLocationCoordinate2DMake(point.latitude, point.longitude)
                mapView.addAnnotation(annotation)
            }
        }
    }
}

