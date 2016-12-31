//
//  ListViewController.swift
//  Pogger
//
//  Created by Taiju Aoki on 2016/02/27.
//  Copyright © 2016年 Taiju Aoki. All rights reserved.
//

import UIKit
import RealmSwift
import GoogleMaps
import DZNEmptyDataSet

enum ListType {
    case records
    case favorites
}

class ListViewController: UIViewController, UITabBarControllerDelegate, UITableViewDataSource, UITableViewDelegate, DZNEmptyDataSetSource, PointCellDelegate {

    var viaTableView: UITableView! {
        return nil
    }

    var listType: ListType! {
        return nil
    }

    private let dispMinuteMin = 10

    private var points: [[Point]]?
    private var selectedPoint: Point?

    var pointCellType: PointCellType = .streetView

    override func viewDidLoad() {
        super.viewDidLoad()
        viaTableView.tableFooterView = UIView()
        viaTableView.emptyDataSetSource = self
        refreshData(completion: viaTableView.reloadData)
        addNotificationObserver()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController!.delegate = self
    }

    //MARK: - TableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return points?.count ?? 0
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let pd = points else {
            return nil
        }
        if pd.isEmpty {
            return nil
        }
        let date = pd[section][0].startDate
        let days = Utils.getDayCnt(to: date)
        var sectionTitle: String?
        switch days {
        case 0:
            sectionTitle = "今日"
        case 1:
            sectionTitle = "昨日"
        default:
            sectionTitle = Utils.getDateString(for: date)
        }
        return sectionTitle
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return points?[section].count ?? 0
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        let row = indexPath.row
        let point = points![section][row]

        let cell: PointCell = tableView.dequeueReusableCell(withIdentifier: "PointCell") as! PointCell
        cell.delegate = self
        cell.setPoint(point, dispMinuteMin: dispMinuteMin, type: self.pointCellType)

        return cell
    }

    func refreshData(completion: (() -> Swift.Void)?) {
        DispatchQueue.main.async {
            defer {
                completion?()
            }
            self.points = []
            switch self.listType! {
            case .records:
                self.setPogList()
            case .favorites:
                self.setFavoriteList()
            }
        }
    }

    private func setPogList() {
        let allPoints = try! Realm().objects(Point.self).sorted(byProperty: "startDate", ascending: false)
        if allPoints.isEmpty {
            return
        }
        let lastPointDate = allPoints[0].startDate

        let predicate = NSPredicate(format: "stayMin >= %d OR startDate = %@", self.dispMinuteMin, lastPointDate as CVarArg)
        let pointsData = allPoints.filter(predicate)

        for point in pointsData {
            // 1個目
            guard let lastDayPoints = self.points!.last else {
                self.points!.append([point])
                continue
            }
            guard let lastPoint = lastDayPoints.last else {
                continue
            }
            if point.startDate.isInSameDayAsDate(lastPoint.startDate) {
                // 同じ日
                self.points![self.points!.count - 1].append(point)
            } else {
                // 違う日
                self.points!.append([point])
            }
        }
    }

    private func setFavoriteList() {
        let predicate = NSPredicate(format: "favorite = true")
        let pointsData = try! Realm().objects(Point.self).sorted(byProperty: "startDate", ascending: false).filter(predicate)
        if pointsData.isEmpty {
            return
        }

        for point in pointsData {
            // 1個目
            guard let lastDayPoints = self.points!.last else {
                self.points!.append([point])
                continue
            }
            guard let lastPoint = lastDayPoints.last else {
                continue
            }
            if point.startDate.isInSameDayAsDate(lastPoint.startDate) {
                // 同じ日
                self.points![self.points!.count - 1].append(point)
            } else {
                // 違う日
                self.points!.append([point])
            }
        }
    }

    //MARK: - Action
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if let points = points {
            selectedPoint = points[indexPath.section][indexPath.row]
        }
        return indexPath
    }

    func pointCell(_ pointCell: PointCell, didTapFavButton select: Bool) {
        Point.switchFavorite(pointCell.id, select: select)
    }

    func didTapShareButton(_ pointCell: PointCell) {
        let point = try! Realm().objects(Point.self).filter("id == \"\(pointCell.id!)\"")[0]
        shouldOpenShare(point)
    }

    private func shouldOpenShare(_ point: Point) {

        let shareText = Utils.getShareText(point)
        let activityVC = UIActivityViewController(activityItems: [shareText, point], applicationActivities: [OpenMapAppActivity()])
        activityVC.view.tintColor = Prefix.themaColor
        present(activityVC, animated: true, completion: nil)
    }

    func didTapOptionButton(_ pointCell: PointCell) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.view.tintColor = Prefix.themaColor
        //TODO: 「この場所を今後無視する」のアクションを追加
        let deleteAction = UIAlertAction(title: "この記録を削除", style: .destructive, handler: {
            action in self.deleteRecord(pointCell)
        })
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        actionSheet.addAction(deleteAction)
        actionSheet.addAction(cancelAction)
        self.present(actionSheet, animated: true, completion: nil)
    }

    func didLongSelect(_ sender: UILongPressGestureRecognizer) {
        let point = sender.location(in: viaTableView)
        let indexPath = viaTableView.indexPathForRow(at: point)!

        if sender.state == .began {
            let point = points![indexPath.section][indexPath.row]

            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            actionSheet.view.tintColor = Prefix.themaColor
            let copyAction = UIAlertAction(title: "住所をコピー", style: .default, handler: {
                action in
                let address = Utils.getAddress(point)
                UIPasteboard.general.setValue(address, forPasteboardType: "public.text")
            })
            let mapOpenAction = UIAlertAction(title: "マップで見る", style: .default, handler: {
                action in //TODO: マップ画面を開く
            })
            let shareAction = UIAlertAction(title: "この記録を共有", style: .default, handler: {
                action in self.shouldOpenShare(point)
            })
            let deleteAction = UIAlertAction(title: "この記録を削除", style: .destructive, handler: {
                action in
                let cell = self.viaTableView.cellForRow(at: indexPath) as! PointCell
                self.deleteRecord(cell)
            })
            let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
            actionSheet.addAction(copyAction)
            actionSheet.addAction(mapOpenAction)
            actionSheet.addAction(shareAction)
            actionSheet.addAction(deleteAction)
            actionSheet.addAction(cancelAction)
            self.present(actionSheet, animated: true, completion: nil)
        }
    }

    private func deleteRecord(_ pointCell: PointCell) {
        // Realm から削除
        let realm = try! Realm()
        let point = realm.objects(Point.self).filter("id == \"\(pointCell.id!)\"")[0]
        try! realm.write {
            realm.delete(point)
        }

        // VC が保持しているデータから削除
        let indexPath = viaTableView.indexPath(for: pointCell)!
        points![indexPath.section].remove(at: indexPath.row)

        // tableView の見た目として削除
        viaTableView.beginUpdates()
        viaTableView.deleteRows(at: [indexPath], with: .automatic)
        viaTableView.endUpdates()
    }

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if tabBarController.selectedIndex == 0 {
            scrollToTop()
        }
    }

    func scrollToTop() {
        viaTableView.setContentOffset(CGPoint(x: 0, y: -viaTableView.contentInset.top), animated: true)
    }

    //MARK : Notification
    private func addNotificationObserver() {
        let nc = NotificationCenter.default
        switch listType! {
        case .records:
            nc.addObserver(
                self,
                selector: #selector(self.addPoint),
                name: NotificationNames.addPoint,
                object: nil)
            nc.addObserver(
                self,
                selector: #selector(self.updatePoint),
                name: NotificationNames.updatePoint,
                object: nil)
        case .favorites:
            nc.addObserver(
                self,
                selector: #selector(self.switchFavorite),
                name: NotificationNames.switchFavorite,
                object: nil)
        }
    }

    func addPoint(notification: Notification?) {
        refreshData(completion: viaTableView.reloadData)
    }

    func updatePoint(notification: Notification?) {
        let cellCnt = self.viaTableView.numberOfSections
        if cellCnt == 0 {
            return
        }
        refreshData(completion: {
            let indexPath = IndexPath(row: 0, section: 0)
            self.viaTableView.beginUpdates()
            self.viaTableView.reloadRows(at: [indexPath], with: .automatic)
            self.viaTableView.endUpdates()
        })
    }

    func switchFavorite(notification: Notification?) {
        refreshData(completion: viaTableView.reloadData)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    //MARK : Transition
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == "toStreetView" {
            let vc: StreetViewController = segue.destination as! StreetViewController
            let coordinater = CLLocationCoordinate2D(latitude: selectedPoint!.latitude, longitude: selectedPoint!.longitude)
            vc.coordinater = coordinater
        }
    }

    //MARK: - DZNEmptyDataSet
    func customView(forEmptyDataSet scrollView: UIScrollView!) -> UIView! {
        let nibName: String!
        if points == nil {
            nibName = "IndicatorView" // 未ロード
        } else {
            switch listType! {
            case .records:
                nibName = "EmptyState"
            case .favorites:
                nibName = "FavoriteEmptyState"
            }
        }
        let nib = UINib(nibName: nibName, bundle:nil)
        return nib.instantiate(withOwner: nil, options: nil).first as! UIView
    }
}
