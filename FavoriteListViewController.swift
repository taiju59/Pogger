//
//  FavoriteListViewController.swift
//  Pogger
//
//  Created by natsuyama on 2016/09/29.
//  Copyright © 2016年 Taiju Aoki. All rights reserved.
//

import UIKit
import RealmSwift
import GoogleMaps
import DZNEmptyDataSet

class FavoriteListViewController: ViewController, UITabBarControllerDelegate, UITableViewDataSource, UITableViewDelegate, DZNEmptyDataSetSource, PointCellDelegate {


    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var configButton: UIButton!

    private let dispMinuteMin = 10
    private let comeBackLimit = 60
    private let dispCellCnt = Int(INT_MAX) // TODO: 表示セル制限

    private var pointsData: [[FixedPoint]]?
    private var selectedPoint: FixedPoint?
    private var pointCellType: PointCellType = .streetView

    private var refreshControl = UIRefreshControl()

    private var token: NotificationToken?

    override func viewDidLoad() {
        super.viewDidLoad()

        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.addSubview(refreshControl)
        tableView.sendSubview(toBack: refreshControl)
        tableView.tableFooterView = UIView()
        tableView.emptyDataSetSource = self

        LocationService.sharedInstance.startUpdatingLocation()

        self.token = try! Realm().addNotificationBlock { note, realm in
            if self.pointsData == nil || self.pointsData!.isEmpty {
                self.refreshData()
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController!.delegate = self
        refreshData()
    }

    //MARK: - TableView
    func numberOfSections(in tableView: UITableView) -> Int {

        let dayCnt = pointsData?.count ?? 0
        return dayCnt// > 5 ? 5:dayCnt
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let pd = pointsData else {
            return nil
        }
        if pd.isEmpty {
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

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pointsData?[section].count ?? 0
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = (indexPath as NSIndexPath).section
        let row = (indexPath as NSIndexPath).row
        let point = pointsData![section][row]

        let cell: PointCell = tableView.dequeueReusableCell(withIdentifier: "PointCell") as! PointCell
        cell.delegate = self
        cell.setPoint(point, dispMinuteMin: dispMinuteMin, type: self.pointCellType)

        return cell
    }

    func refreshData() {
        let private_queue = DispatchQueue(label: "refreshData", attributes: [])
        private_queue.async {
            defer {
                DispatchQueue.main.async {
                    self.refreshControl.endRefreshing()
                    self.tableView.reloadData()
                }
            }
            self.pointsData = []
            self.setFavoriteList()
        }
    }

    private func setPogList() {
        let allPoints = try! Realm().objects(Point.self).sorted(byProperty: "startDate", ascending: false)
        if allPoints.isEmpty {
            return
        }
        let lastPointDate = allPoints[0].startDate!

        let predicate = NSPredicate(format: "stayMin >= %d OR startDate = %@", self.dispMinuteMin, lastPointDate as CVarArg)
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
            if self.pointsData.flatMap({$0})!.count >= self.dispCellCnt {
                // 表示限界越え
                break
            }
        }
    }

    private func setFavoriteList() {
        let predicate = NSPredicate(format: "favorite = true")
        let points = try! Realm().objects(Point.self).sorted(byProperty: "startDate", ascending: false).filter(predicate)
        if points.isEmpty {
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
            if self.pointsData.flatMap({$0})!.count >= self.dispCellCnt {
                // 表示限界超え
                break
            }
        }
    }

    //MARK: - Action
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if let points = pointsData {
            selectedPoint = points[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
        }
        return indexPath
    }

    func pointCell(_ pointCell: PointCell, didTapFavButton select: Bool) {
        print("id: \(pointCell.id), select: \(select)")
        Point.switchFavorite(pointCell.id, select: select)
    }

    /*
     @IBAction func changePogList(_ sender: UISegmentedControl) {
     let value = sender.selectedSegmentIndex
     pogListType = value
     refreshData()
     }
     */
    /*
    @IBAction func changeViewType(_ sender: UIBarButtonItem) {
        let private_queue = DispatchQueue(label: "changeViewType", attributes: [])
        private_queue.async {
            switch self.pointCellType {
            case .streetView:
                self.pointCellType = .map
            case .map:
                self.pointCellType = .streetView
            }
            let userDefaults = UserDefaults.standard
            userDefaults.set(self.pointCellType.rawValue, forKey: Prefix.keypointCellType)
            userDefaults.synchronize()
            DispatchQueue.main.async {
                self.refreshData()
            }
        }
    }
    */

    @IBAction func didLongSelect(_ sender: UILongPressGestureRecognizer) {
        let point = sender.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: point)!

        if sender.state == .began {
            let point = pointsData![(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]

            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let copyAction = UIAlertAction(title: "住所をコピー", style: .default, handler: {
                action in self.copyAddress(point)
            })
            let mapOpenAction = UIAlertAction(title: "マップで見る", style: .default, handler: {
                action in self.shouldOpenMap(point)
            })
            let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
            actionSheet.addAction(copyAction)
            actionSheet.addAction(mapOpenAction)
            actionSheet.addAction(cancelAction)
            self.present(actionSheet, animated: true, completion: nil)
        }
    }

    private func copyAddress(_ point: FixedPoint) {
        let name = point.name ?? ""
        let locality = point.locality ?? ""
        let address = "\(name),\(locality)"
        let board = UIPasteboard.general
        board.setValue(address, forPasteboardType: "public.text")
    }

    private func shouldOpenMap(_ point: FixedPoint) {
        let ll = String(format: "%f,%f", point.latitude, point.longitude)
        let name = point.name ?? ""
        let locality = point.locality ?? ""
        let q = "\(name),\(locality)"

        let urlString: String
        if UIApplication.shared.canOpenURL(URL(string: "comgooglemaps://")!) {
            urlString = "comgooglemaps://?center=\(ll)&q=\(q)"
        } else {
            urlString = "http://maps.apple.com/?ll=\(ll)&q=\(q)"
        }
        let encodedUrl = urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let url = URL(string: encodedUrl)!
        UIApplication.shared.openURL(url)
    }

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        scrollToTop()
    }

    private func scrollToTop() {
        tableView.setContentOffset(CGPoint.zero, animated: true)
    }
    
    //MARK : Transition
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == "toStreetView" {
            let vc = segue.destination as! StreetViewController
            vc.panoramaID = (sender! as AnyObject).panorama?!.panoramaID
        } else if segue.identifier == "Cell2StreetView" && selectedPoint != nil {
            let vc: StreetViewController = segue.destination as! StreetViewController
            let coordinater = CLLocationCoordinate2D(latitude: selectedPoint!.latitude, longitude: selectedPoint!.longitude)
            vc.coordinater = coordinater
        }
    }
    /*
    @IBAction func returnListViewForSegue(_ segue: UIStoryboardSegue) {

    }*/

    //MARK: - DZNEmptyDataSet
    func customView(forEmptyDataSet scrollView: UIScrollView!) -> UIView! {
        let nib = UINib(nibName: "FavoriteEmptyState", bundle:nil)
        return nib.instantiate(withOwner: nil, options: nil).first as! UIView
    }
}
