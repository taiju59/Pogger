//
//  PointCell.swift
//  Pogger
//
//  Created by Taiju Aoki on 2016/04/17.
//  Copyright © 2016年 Taiju Aoki. All rights reserved.
//

import UIKit
import GoogleMaps
import MapKit

protocol PointCellDelegate: class {
    func pointCell(pointCell: PointCell, didTapFavButton select: Bool)
}

enum PointCellType: Int {
    case StreetView
    case Map
}

class PointCell: UITableViewCell {

    var delegate: PointCellDelegate?

    var id: String!

    @IBOutlet weak var mainContentsView: UIView!
    @IBOutlet weak var administrativeAreaButton: UIButton!
    @IBOutlet weak var subLocalityButton: UIButton!
    @IBOutlet weak var localityButton: UIButton!
    @IBOutlet weak var thoroughfareButton: UIButton!
    @IBOutlet weak var subThoroughfareButton: UIButton!
    @IBOutlet weak var nameButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var favButton: DOFavoriteButton!

    @IBOutlet weak var comma1: UILabel!
    @IBOutlet weak var comma2: UILabel!
    @IBOutlet weak var comma3: UILabel!
    @IBOutlet weak var comma4: UILabel!
    @IBOutlet weak var comma5: UILabel!

    func setPoint(point: FixedPoint, dispMinuteMin: Int, type: PointCellType) {

        for subview in self.mainContentsView.subviews {
            subview.removeFromSuperview()
        }

        // 背景色
        if point.stayMin < dispMinuteMin && !point.favorite {
            self.backgroundColor = Prefix.themaColor.colorWithAlphaComponent(0.2)
        } else {
            self.backgroundColor = UIColor.whiteColor()
        }

        // 住所
        self.setAddress(point)

        // 時間ラベル
        self.dateLabel.text = Utils.getStayDateStr(point)

        // お気に入り
        self.id = point.id
        self.favButton.selected = point.favorite

        // ストリートビュー/マップを表示
        switch type {
        case .StreetView:
            let panoView = getPanoView(point)
            self.mainContentsView.addSubview(panoView)
        case .Map:
            let mapView = getMapView(point)
            self.mainContentsView.addSubview(mapView)
        }
    }

    private func setAddress(point: FixedPoint) {

        let name = point.name ?? ""
        let subThoroughfare = point.subThoroughfare ?? ""
        let thoroughfare = point.thoroughfare ?? ""
        let subLocality = point.subLocality ?? ""
        let locality = point.locality ?? ""
        let administrativeArea = point.administrativeArea ?? ""

        // 今のところ name と locality のみ表示
        let showName = true && !name.isEmpty
        let showSubThoroughfare = false && !subThoroughfare.isEmpty
        let showThoroughfare = false && !thoroughfare.isEmpty
        let showSubLocality = false && !subLocality.isEmpty
        let showLocality = true && !locality.isEmpty
        let showAdministrativeArea = false && !administrativeArea.isEmpty

        self.nameButton.hidden = !showName
        self.subThoroughfareButton.hidden = !showSubThoroughfare
        self.thoroughfareButton.hidden = !showThoroughfare
        self.subLocalityButton.hidden = !showSubLocality
        self.localityButton.hidden = !showLocality
        self.administrativeAreaButton.hidden = !showAdministrativeArea

        self.comma1.hidden = !showSubThoroughfare
        self.comma2.hidden = !showThoroughfare
        self.comma3.hidden = !showSubLocality
        self.comma4.hidden = !showLocality
        self.comma5.hidden = !showAdministrativeArea

        self.nameButton.setTitle(name, forState: .Normal)
        self.subThoroughfareButton.setTitle(subThoroughfare, forState: .Normal)
        self.thoroughfareButton.setTitle(thoroughfare, forState: .Normal)
        self.subLocalityButton.setTitle(subLocality, forState: .Normal)
        self.localityButton.setTitle(locality, forState: .Normal)
        self.administrativeAreaButton.setTitle(administrativeArea, forState: .Normal)
    }

    @IBAction func favTapped(sender: DOFavoriteButton) {
        if sender.selected {
            // deselect
            sender.deselect()
            delegate?.pointCell(self, didTapFavButton: false)
        } else {
            // select with animation
            sender.select()
            delegate?.pointCell(self, didTapFavButton: true)
        }
    }

    private func getPanoView(point: FixedPoint) -> GMSPanoramaView {

        //TODO: auto layout で作成
        let deviceWidth = UIScreen.mainScreen().bounds.width
        let rect = CGRect(x: 0, y: 0, width: deviceWidth - 16, height: 100)
        let location = CLLocationCoordinate2D(latitude: point.latitude, longitude: point.longitude)

        let panoView = GMSPanoramaView.panoramaWithFrame(rect, nearCoordinate: location)
        panoView.setAllGesturesEnabled(false)
        panoView.navigationLinksHidden = true
        panoView.streetNamesHidden = true
        panoView.userInteractionEnabled = false // タッチイベントを透過
        return panoView
    }

    private func getMapView(point: FixedPoint) -> MKMapView {

        let deviceWidth = UIScreen.mainScreen().bounds.width
        let rect = CGRect(x: 0, y: 0, width: deviceWidth - 16, height: 100)
        let location = CLLocationCoordinate2D(latitude: point.latitude, longitude: point.longitude)

        let mapView = MKMapView(frame: rect)
        mapView.centerCoordinate = location
        let latDist: CLLocationDistance = 100
        let lonDist: CLLocationDistance = 100
        let region = MKCoordinateRegionMakeWithDistance(location, latDist, lonDist)
        mapView.setRegion(region, animated: false)
        return mapView
    }
}
