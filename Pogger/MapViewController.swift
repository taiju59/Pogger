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

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var selectTermButton: UIBarButtonItem!

    fileprivate var termValue = 7

    fileprivate let indicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)

    override func viewDidLoad() {
        super.viewDidLoad()
        indicator.stopAnimating()
        indicator.frame = self.view.frame
        indicator.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.3)
        self.view.addSubview(indicator)

        addNotificationObserver()
        trySetMap()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController!.delegate = self
        setPins()
    }

    /**
     * 最新の位置情報を地図の中心にする.
     * なければローディング表示.
     */
    fileprivate func trySetMap() {
        // 最新の位置情報を地図の中心にする
        if let location = LocationService.sharedInstance.newestLocation {
            setMap(for: location)
        } else {
            //TODO: 待ち受け状態にする
            indicator.startAnimating()
        }
    }

    fileprivate func setMap(for location: CLLocation) {
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude

        //中心座標
        let center = CLLocationCoordinate2DMake(latitude, longitude)

        //表示範囲
        let span = MKCoordinateSpanMake(0.03, 0.03)

        //中心座標と表示範囲をマップに登録する。
        let region = MKCoordinateRegionMake(center, span)
        mapView.setRegion(region, animated: true)
    }

    /**
     * ピンを刺す
     */
    fileprivate func setPins() {
        let points = getTargetPoints()
        updatePins(for: points)
    }

    /**
     * 対象地点情報を取得
     */
    private func getTargetPoints() -> [Point] {
        let points: Results<Point>
        if termValue == 0 {
            // 表示期間「すべて」の場合
            points = try! Realm().objects(Point.self)
        } else {
            let timeInterval = -60 * 60 * 24  * termValue
            let term = Date(timeInterval: TimeInterval(timeInterval), since: Date())
            let predicate = NSPredicate(format: "startDate >= %@", term as CVarArg)
            points = try! Realm().objects(Point.self).filter(predicate)
        }

        let dispMinuteMin = 10 //TODO: 設定値として他画面と共通して管理する
        return points.filter {$0.stayMin > dispMinuteMin}
    }

    /**
     * 指定地点且つ地図表示範囲にピンを刺す
     */
    private func updatePins(for points: [Point]) {
        //地図上のピンを削除
        mapView.removeAnnotations(mapView.annotations)

        let mRect = mapView.visibleMapRect
        //Map画面上の中心座標
        let topMapPoint = MKMapPointMake(MKMapRectGetMidX(mRect), MKMapRectGetMinY(mRect))
        //Map画面下の中心座表
        let bottomMapPoint = MKMapPointMake(MKMapRectGetMidX(mRect), MKMapRectGetMaxY(mRect))
        let radius = MKMetersBetweenMapPoints(topMapPoint, bottomMapPoint) / 2

        //地図にピンを立てる。
        for point in points {
            //中心座標取得
            let centerPoint = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
            //一つ一つのピンの座標を取得
            let pinPoint = CLLocation(latitude: point.latitude, longitude: point.longitude)
            let distance = centerPoint.distance(from: pinPoint)
            let annotation = MKPointAnnotation()
            annotation.title = Utils.getAddress(point)
            annotation.subtitle = Utils.getAnnotationDateStr(point)
            if radius > distance {
                annotation.coordinate = CLLocationCoordinate2DMake(point.latitude, point.longitude)
                mapView.addAnnotation(annotation)
            }
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

//MARK: - Delegate
extension MapViewController: UITabBarControllerDelegate, SelectTermViewControllerDelegate, MKMapViewDelegate {

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if tabBarController.selectedIndex == 1 {
            trySetMap()
        }
    }

    //Mapが更新されるたびに呼び出される
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        setPins()
    }

    func selectTermViewController(_ selectTermViewController: SelectTermViewController, didSelectTerm value: Int, title: String) {
        termValue = value
        selectTermButton.title = title
    }
}

//MARK: - Notification
extension MapViewController {

    fileprivate func addNotificationObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.updateNewestLocation),
            name: NotificationNames.updateNewestLocation,
            object: nil)
    }

    func updateNewestLocation(notification: Notification?) {
        let location = LocationService.sharedInstance.newestLocation!
        setMap(for: location)
        indicator.stopAnimating()
    }

}
