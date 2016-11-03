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

class MapViewController: UIViewController, UITabBarControllerDelegate, SelectTermViewControllerDelegate, MKMapViewDelegate {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var selectTermButton: UIBarButtonItem!

    private var termValue = 7

    override func viewDidLoad() {
        super.viewDidLoad()
        setMap()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController!.delegate = self
        setPins()
    }

    private func setMap() {
        //sharedInstanceによる値渡し(経度緯度)
        let latitude = LocationService.sharedInstance.newestLocation.coordinate.latitude
        let longitude = LocationService.sharedInstance.newestLocation.coordinate.longitude

        //中心座標
        let center = CLLocationCoordinate2DMake(latitude, longitude)

        //表示範囲
        let span = MKCoordinateSpanMake(0.03, 0.03)

        //中心座標と表示範囲をマップに登録する。
        let region = MKCoordinateRegionMake(center, span)
        mapView.setRegion(region, animated: true)
    }

    private func setPins() {
        let dispMinuteMin = 10 //TODO: 設定値として他画面と共通して管理する
        let predicate: NSPredicate
        if termValue == 0 {
            // 表示期間「すべて」の場合
            predicate = NSPredicate(format: "stayMin >= %d", dispMinuteMin)
        } else {
            let timeInterval = -60 * 60 * 24  * termValue
            let term = Date(timeInterval: TimeInterval(timeInterval), since: Date())
            predicate = NSPredicate(format: "stayMin >= %d AND startDate >= %@", dispMinuteMin, term as CVarArg)
        }
        let points = try! Realm().objects(Point.self).filter(predicate)

        let mRect = mapView.visibleMapRect
        //Map画面上の中心座標
        let topMapPoint = MKMapPointMake(MKMapRectGetMidX(mRect), MKMapRectGetMinY(mRect))
        //Map画面下の中心座表
        let bottomMapPoint = MKMapPointMake(MKMapRectGetMidX(mRect), MKMapRectGetMaxY(mRect))
        let radius = MKMetersBetweenMapPoints(topMapPoint, bottomMapPoint) / 2

        updatePins(for: points, radius: radius)
    }

    private func updatePins(for points: RealmSwift.Results<Point>, radius: CLLocationDistance) {
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
            annotation.title = Utils.getAnnotationDateStr(point)
            annotation.subtitle = "\(point.name!),\(point.locality!)"
            if radius > distance {
                annotation.coordinate = CLLocationCoordinate2DMake(point.latitude, point.longitude)
                mapView.addAnnotation(annotation)
            }
        }
    }

    //MARK: - Action
    //Mapが更新されるたびに呼び出される
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        setPins()
    }

    func selectTermViewController(_ selectTermViewController: SelectTermViewController, didSelectTerm value: Int, title: String) {
        termValue = value
        selectTermButton.title = title
    }

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if tabBarController.selectedIndex == 1 {
            setMap()
        }
    }

    //MARK: - Transition
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == "toSelectTermView" {
            let vc = segue.destination as! SelectTermViewController
            vc.delegate = self
        }
    }
}
