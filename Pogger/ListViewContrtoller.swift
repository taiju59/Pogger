//
//  ListViewContrtoller.swift
//  Pogger
//
//  Created by Taiju Aoki on 2016/04/17.
//  Copyright © 2016年 Taiju Aoki. All rights reserved.
//

import UIKit
import RealmSwift
import GoogleMaps
import MapKit
import SwiftDate
import DZNEmptyDataSet

class ListViewController: ViewController, UITableViewDataSource, UITableViewDelegate, DZNEmptyDataSetSource, PointCellDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var configButton: UIButton!
    
    private let DISP_MINITUE_MIN = 10
    private let COME_BACK_LIMIT = 60
    private let DISP_CELL_CNT = Int(INT_MAX) // TODO: 表示セル制限
    
    private var pointsData: [[FixedPoint]]?
    private var selectedPoint: FixedPoint?
    private var showStreetView = true
    
    private var refreshControl = UIRefreshControl()
    
    private var token: NotificationToken?
    
    private var pogListType = 0 // 0: pog, 1: favorite

    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl.addTarget(self, action: #selector(refreshData), forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl)
        tableView.sendSubviewToBack(refreshControl)
        tableView.tableFooterView = UIView()
        tableView.emptyDataSetSource = self
        
        LocationModel.sharedInstance.startUpdatingLocation()
        
        configButton.setTitle(Prefix.ICON_CONF, forState: .Normal)
        
        self.token = try! Realm().addNotificationBlock { note, realm in
            if self.pointsData == nil || self.pointsData!.count == 0 {
                self.refreshData()
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        refreshData()
    }
    
    //MARK: - TableView
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        let dayCnt = pointsData?.count ?? 0
        return dayCnt// > 5 ? 5:dayCnt
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let pd = pointsData else {
            return nil
        }
        if pd.count == 0 {
            return nil
        }
        guard let date = pd[section][0].startDate else {
            return nil
        }
        
        let days = Utils.daysFromDate(date)
        var sectionTitle: String?
        switch days {
        case 0:
            sectionTitle = "今日"
        case 1:
            sectionTitle = "昨日"
        default:
            sectionTitle = Utils.stringFromDate(date)
        }
        return sectionTitle
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return pointsData?[section].count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        return getPointCell(indexPath)
    }
    
    private func getPointCell(indexPath: NSIndexPath) -> PointCell {

        let cell: PointCell = tableView.dequeueReusableCellWithIdentifier("PointCell") as! PointCell
        
        for subview in cell.mainContentsView.subviews {
            subview.removeFromSuperview()
        }
        
        let section = indexPath.section
        let row = indexPath.row
        if pointsData == nil || pointsData?.count <= section || pointsData?[section].count <= row {
            return cell
        }
        
        let point = pointsData![section][row]
        

        // 背景色
        if point.stayMin < DISP_MINITUE_MIN && !point.favorite {
            cell.backgroundColor = Prefix.THEMA_COLOR.colorWithAlphaComponent(0.2)
        } else {
            cell.backgroundColor = UIColor.whiteColor()
        }
        
        // 住所
        setAddress(cell, point: point)
        
        // 時間ラベル
        cell.dateLabel.text = getStayDateStr(point)
        
        // お気に入り
        cell.delegate = self
        cell.id = point.id
        cell.favButton.selected = point.favorite
        
        // ストリートビュー/マップを表示
        if showStreetView {
            let panoView = getPanoView(point)
            cell.mainContentsView.addSubview(panoView)
        } else {
            let mapView = getMapView(point)
            cell.mainContentsView.addSubview(mapView)
        }
        
        return cell
    }
    
    private func setAddress(cell: PointCell, point: FixedPoint) -> PointCell {

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
        
        cell.nameButton.hidden = !showName
        cell.subThoroughfareButton.hidden = !showSubThoroughfare
        cell.thoroughfareButton.hidden = !showThoroughfare
        cell.subLocalityButton.hidden = !showSubLocality
        cell.localityButton.hidden = !showLocality
        cell.administrativeAreaButton.hidden = !showAdministrativeArea

        cell.comma1.hidden = !showSubThoroughfare
        cell.comma2.hidden = !showThoroughfare
        cell.comma3.hidden = !showSubLocality
        cell.comma4.hidden = !showLocality
        cell.comma5.hidden = !showAdministrativeArea
        
        cell.nameButton.setTitle(name, forState: .Normal)
        cell.subThoroughfareButton.setTitle(subThoroughfare, forState: .Normal)
        cell.thoroughfareButton.setTitle(thoroughfare, forState: .Normal)
        cell.subLocalityButton.setTitle(subLocality, forState: .Normal)
        cell.localityButton.setTitle(locality, forState: .Normal)
        cell.administrativeAreaButton.setTitle(administrativeArea, forState: .Normal)
        
        return cell
    }
    
    private func getStayDateStr(point: FixedPoint) -> String {

        let startDate = point.startDate
        let endDate = point.endDate
        var dateText = ""
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM/dd HH:mm"

        let startDateStr = dateFormatter.stringFromDate(startDate)
        dateText += startDateStr

        if startDate.isEqualToDate(endDate) {
            return dateText
        }
        
        if endDate.isInSameDayAsDate(startDate) {
            let endDateStr = String(format: "%02d:%02d", endDate.hour, endDate.minute)
            dateText += " - \(endDateStr)"
            return dateText
        } else {
            let endDateStr = dateFormatter.stringFromDate(endDate)
            dateText += " - \(endDateStr)"
            return dateText
        }
    }
    
    private func getPanoView(point: FixedPoint) -> GMSPanoramaView {
        
        let deviceWidth = UIScreen.mainScreen().bounds.width
        let rect = CGRect(x: 0, y: 0, width: deviceWidth - 16, height: 100)
        let location = CLLocationCoordinate2D(latitude: point.latitude, longitude: point.longitude)
        
        let panoView = GMSPanoramaView.panoramaWithFrame(rect, nearCoordinate: location)
        panoView.setAllGesturesEnabled(false)
        panoView.navigationLinksHidden = true
        panoView.streetNamesHidden = true
        // タッチイベントを透過させる
        panoView.userInteractionEnabled = false
        return panoView
    }
    
    private func getMapView(point: FixedPoint) -> MKMapView {
        
        let deviceWidth = UIScreen.mainScreen().bounds.width
        let rect = CGRect(x: 0, y: 0, width: deviceWidth - 16, height: 100)
        let location = CLLocationCoordinate2D(latitude: point.latitude, longitude: point.longitude)
        
        let mapView = MKMapView(frame: rect)
        mapView.centerCoordinate = location
        let latDist : CLLocationDistance = 100
        let lonDist : CLLocationDistance = 100
        let region = MKCoordinateRegionMakeWithDistance(location, latDist, lonDist)
        mapView.setRegion(region, animated: false)
        return mapView
    }
    
    func refreshData() {
        let private_queue = dispatch_queue_create("refreshData", nil)
        dispatch_async(private_queue) {
            defer {
                dispatch_async(dispatch_get_main_queue()) {
                    self.refreshControl.endRefreshing()
                    self.tableView.reloadData()
                }
            }
            self.pointsData = []
            if self.pogListType == 0 {
                self.setPogList()
            } else {
                self.setFavoriteList()
            }
            
//            let userDefaults = NSUserDefaults.standardUserDefaults()
//            self.showStreetView = userDefaults.boolForKey(Prefix.KEY_SHOW_STREET_VIEW)
        }
    }
    
    private func setPogList() {
        let allPoints = try! Realm().objects(Point).sorted("startDate", ascending: false)
        if allPoints.count == 0 {
            return
        }
        let lastPointDate = allPoints[0].startDate!
        
        let predicate = NSPredicate(format: "stayMin >= %d OR startDate = %@", self.DISP_MINITUE_MIN, lastPointDate)
        let points = allPoints.filter(predicate)
        
        for point in points {
            let fPoint = FixedPoint(rlm: point)
            // 1個目
            guard let lastDayPoints = self.pointsData!.last else {
                self.pointsData!.append([fPoint])
                continue
            }
            guard let lastPoint = lastDayPoints.last else {
                // 通らないはず
                continue
            }
            if fPoint.startDate!.isInSameDayAsDate(lastPoint.startDate!) {
                // 同じ日
                self.pointsData![self.pointsData!.count - 1].append(fPoint)
            } else {
                // 違う日
                self.pointsData!.append([fPoint])
            }
            if self.pointsData.flatMap({$0})!.count >= self.DISP_CELL_CNT {
                // 表示限界越え
                break
            }
        }
    }
    
    private func setFavoriteList() {
        let predicate = NSPredicate(format: "favorite = true")
        let points = try! Realm().objects(Point).sorted("startDate", ascending: false).filter(predicate)
        if points.count == 0 {
            return
        }
        
        for point in points {
            let fPoint = FixedPoint(rlm: point)
            // 1個目
            guard let lastDayPoints = self.pointsData!.last else {
                self.pointsData!.append([fPoint])
                continue
            }
            guard let lastPoint = lastDayPoints.last else {
                // 通らないはず
                continue
            }
            if fPoint.startDate!.isInSameDayAsDate(lastPoint.startDate!) {
                // 同じ日
                self.pointsData![self.pointsData!.count - 1].append(fPoint)
            } else {
                // 違う日
                self.pointsData!.append([fPoint])
            }
            if self.pointsData.flatMap({$0})!.count >= self.DISP_CELL_CNT {
                // 表示限界超え
                break
            }
        }
    }

    //MARK: - Action
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if let points = pointsData {
            selectedPoint = points[indexPath.section][indexPath.row]
        }
        return indexPath
    }

    func pointCell(pointCell: PointCell, didTapFavButton select: Bool) {
        print("id: \(pointCell.id), select: \(select)")
        Point.switchFavorite(pointCell.id, select: select)
    }

    @IBAction func changePogList(sender: UISegmentedControl) {
        let value = sender.selectedSegmentIndex
        pogListType = value
        refreshData()
    }
    
    @IBAction func changeViewType(sender: UIBarButtonItem) {
        let private_queue = dispatch_queue_create("changeViewType", nil)
        dispatch_async(private_queue) {
            self.showStreetView = !self.showStreetView
            let userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.setBool(self.showStreetView, forKey: Prefix.KEY_SHOW_STREET_VIEW)
            userDefaults.synchronize()
            dispatch_async(dispatch_get_main_queue()) {
                self.refreshData()
            }
        }
    }

    @IBAction func didLongSelect(sender: UILongPressGestureRecognizer) {
        let point = sender.locationInView(tableView)
        let indexPath = tableView.indexPathForRowAtPoint(point)!
        
        if sender.state == .Began  {
            let point = pointsData![indexPath.section][indexPath.row]
            
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
            let copyAction = UIAlertAction(title: "住所をコピー", style: .Default, handler: {
                action in self.copyAddress(point)
            })
            let mapOpenAction = UIAlertAction(title: "マップで見る", style: .Default, handler: {
                action in self.shouldOpenMap(point)
            })
            let cancelAction = UIAlertAction(title: "キャンセル", style: .Cancel, handler: nil)
            actionSheet.addAction(copyAction)
            actionSheet.addAction(mapOpenAction)
            actionSheet.addAction(cancelAction)
            self.presentViewController(actionSheet, animated: true, completion: nil)
        }
    }
    
    private func copyAddress(point: FixedPoint) {
        let name = point.name ?? ""
        let locality = point.locality ?? ""
        let address = "\(name),\(locality)"
        let board = UIPasteboard.generalPasteboard()
        board.setValue(address, forPasteboardType: "public.text")
    }
    
    private func shouldOpenMap(point: FixedPoint) {
        let ll = String(format: "%f,%f", point.latitude, point.longitude)
        let name = point.name ?? ""
        let locality = point.locality ?? ""
        let q = "\(name),\(locality)"
        
        let urlString: String
        if UIApplication.sharedApplication().canOpenURL(NSURL(string: "comgooglemaps://")!) {
            urlString = "comgooglemaps://?center=\(ll)&q=\(q)"
        } else {
            urlString = "http://maps.apple.com/?ll=\(ll)&q=\(q)"
        }
        let encodedUrl = urlString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        let url = NSURL(string: encodedUrl)!
        UIApplication.sharedApplication().openURL(url)
    }

    @IBAction func didTapLogo(sender: UIButton) {
        let statusBarHeight: CGFloat = UIApplication.sharedApplication().statusBarFrame.height
        let navBarHeight: CGFloat = self.navigationController?.navigationBar.frame.size.height ?? 0
        tableView.setContentOffset(CGPoint(x: 0, y: -(statusBarHeight + navBarHeight)), animated: true)
    }

    //MARK : Transition
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        if segue.identifier == "toStreetView" {
            let vc: StreetViewController = segue.destinationViewController as! StreetViewController
            vc.panoramaID = sender!.panorama?!.panoramaID
        } else if segue.identifier == "Cell2StreetView" && selectedPoint != nil {
            let vc: StreetViewController = segue.destinationViewController as! StreetViewController
            let coordinater = CLLocationCoordinate2D(latitude: selectedPoint!.latitude, longitude: selectedPoint!.longitude)
            vc.coordinater = coordinater
        }
    }

    @IBAction func returnListViewForSegue(segue: UIStoryboardSegue) {

    }

    //MARK: - DZNEmptyDataSet
    func customViewForEmptyDataSet(scrollView: UIScrollView!) -> UIView! {
        if pogListType == 0 {
            let nib = UINib(nibName: "EmptyState",  bundle:nil)
            return nib.instantiateWithOwner(nil, options: nil).first as! UIView
        } else {
            let nib = UINib(nibName: "FavoriteEmptyState",  bundle:nil)
            return nib.instantiateWithOwner(nil, options: nil).first as! UIView
        }
    }
}