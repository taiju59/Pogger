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
    func pointCell(_ pointCell: PointCell, didTapFavButton select: Bool)
    func didTapShareButton(_ pointCell: PointCell)
    func didTapOptionButton(_ pointCell: PointCell)
}

enum PointCellType: Int {
    case streetView
    case map
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
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var optionButton: UIButton!

    @IBOutlet weak var comma1: UILabel!
    @IBOutlet weak var comma2: UILabel!
    @IBOutlet weak var comma3: UILabel!
    @IBOutlet weak var comma4: UILabel!
    @IBOutlet weak var comma5: UILabel!

    func setPoint(_ point: FixedPoint, dispMinuteMin: Int, type: PointCellType) {

        for subview in self.mainContentsView.subviews {
            subview.removeFromSuperview()
        }

        // 背景色
        if point.stayMin < dispMinuteMin && !point.favorite {
            self.backgroundColor = Prefix.themaColor.withAlphaComponent(0.2)
        } else {
            self.backgroundColor = UIColor.white
        }

        // 住所
        self.setAddress(point)

        // 時間ラベル
        self.dateLabel.text = Utils.getStayDateStr(point)

        // お気に入り
        self.id = point.id
        self.favoriteButton.isSelected = point.favorite

        // ストリートビュー/マップを表示
        switch type {
        case .streetView:
            let panoView = getPanoView(point)
            self.mainContentsView.addSubview(panoView)
        case .map:
            let mapView = getMapView(point)
            self.mainContentsView.addSubview(mapView)
        }
    }

    private func setAddress(_ point: FixedPoint) {

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

        self.nameButton.isHidden = !showName
        self.subThoroughfareButton.isHidden = !showSubThoroughfare
        self.thoroughfareButton.isHidden = !showThoroughfare
        self.subLocalityButton.isHidden = !showSubLocality
        self.localityButton.isHidden = !showLocality
        self.administrativeAreaButton.isHidden = !showAdministrativeArea

        self.comma1.isHidden = !showSubThoroughfare
        self.comma2.isHidden = !showThoroughfare
        self.comma3.isHidden = !showSubLocality
        self.comma4.isHidden = !showLocality
        self.comma5.isHidden = !showAdministrativeArea

        self.nameButton.setTitle(name, for: UIControlState())
        self.subThoroughfareButton.setTitle(subThoroughfare, for: UIControlState())
        self.thoroughfareButton.setTitle(thoroughfare, for: UIControlState())
        self.subLocalityButton.setTitle(subLocality, for: UIControlState())
        self.localityButton.setTitle(locality, for: UIControlState())
        self.administrativeAreaButton.setTitle(administrativeArea, for: UIControlState())
    }

    //お気に入りボタンが押された時の処理
    @IBAction func didTapFav(_ sender: UIButton) {
        delegate?.pointCell(self, didTapFavButton: sender.isSelected)
        sender.isSelected = !sender.isSelected
    }

    @IBAction func didTapShare(_ sender: UIButton) {
        delegate?.didTapShareButton(self)
    }

    @IBAction func didTapOption(_ sender: UIButton) {
        delegate?.didTapOptionButton(self)
    }

    private func getPanoView(_ point: FixedPoint) -> GMSPanoramaView {

        //TODO: auto layout で作成
        let deviceWidth = UIScreen.main.bounds.width
        let rect = CGRect(x: 0, y: 0, width: deviceWidth, height: 150)
        let location = CLLocationCoordinate2D(latitude: point.latitude, longitude: point.longitude)

        let panoView = GMSPanoramaView.panorama(withFrame: rect, nearCoordinate: location)
        panoView.setAllGesturesEnabled(false)
        panoView.navigationLinksHidden = true
        panoView.streetNamesHidden = true
        panoView.isUserInteractionEnabled = false // タッチイベントを透過
        return panoView
    }

    private func getMapView(_ point: FixedPoint) -> MKMapView {

        let deviceWidth = UIScreen.main.bounds.width
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
