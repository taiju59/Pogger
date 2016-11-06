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
    private let comeBackLimit = 60
    private let dispCellCnt = Int(INT_MAX) // TODO: 表示セル制限

    private var pointsData: [[FixedPoint]]?
    private var selectedPoint: FixedPoint?

    private var token: NotificationToken?

    var pointCellType: PointCellType = .streetView

    override func viewDidLoad() {
        super.viewDidLoad()
        viaTableView.tableFooterView = UIView()
        viaTableView.emptyDataSetSource = self

        self.token = try! Realm().addNotificationBlock { note, realm in
            self.refreshData(completion: self.viaTableView.reloadData)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController!.delegate = self
        refreshData(completion: viaTableView.reloadData)
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
        return pointsData?[section].count ?? 0
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = (indexPath as IndexPath).section
        let row = (indexPath as IndexPath).row
        let point = pointsData![section][row]

        let cell: PointCell = tableView.dequeueReusableCell(withIdentifier: "PointCell") as! PointCell
        cell.delegate = self
        cell.setPoint(point, dispMinuteMin: dispMinuteMin, type: self.pointCellType)

        return cell
    }

    func refreshData(completion: (() -> Swift.Void)?) {
        let private_queue = DispatchQueue(label: "refreshData", attributes: [])
        private_queue.async {
            defer {
                DispatchQueue.main.async {
                    completion?()
                }
            }
            self.pointsData = []
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
            if fPoint.startDate.isInSameDayAsDate(lastPoint.startDate!) {
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
            if fPoint.startDate.isInSameDayAsDate(lastPoint.startDate!) {
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
            selectedPoint = points[(indexPath as IndexPath).section][(indexPath as IndexPath).row]
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
        let activityItems = [shareText, point] as [Any]

        let applicationActivities = [OpenMapAppActivity()]
        let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
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
            let point = pointsData![(indexPath as IndexPath).section][(indexPath as IndexPath).row]

            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            actionSheet.view.tintColor = Prefix.themaColor
            let copyAction = UIAlertAction(title: "住所をコピー", style: .default, handler: {
                action in
                let board = UIPasteboard.general
                let address = Utils.getAddress(point.toRlmPoint())
                board.setValue(address, forPasteboardType: "public.text")
            })
            let mapOpenAction = UIAlertAction(title: "マップで見る", style: .default, handler: {
                action in //TODO: マップ画面を開く
            })
            let shareAction = UIAlertAction(title: "この記録を共有", style: .default, handler: {
                action in self.shouldOpenShare(point.toRlmPoint())
            })
            let deleteAction = UIAlertAction(title: "この記録を削除", style: .destructive, handler: {
                action in self.deleteRecord(self.viaTableView.cellForRow(at: indexPath) as! PointCell)
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
        let indexPath = viaTableView.indexPath(for: pointCell)!

        // VC が保持しているデータから削除
        pointsData![indexPath.section].remove(at: indexPath.row)

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
        switch listType! {
        case .records:
            nibName = "EmptyState"
        case .favorites:
            nibName = "FavoriteEmptyState"
        }
        let nib = UINib(nibName: nibName, bundle:nil)
        return nib.instantiate(withOwner: nil, options: nil).first as! UIView
    }
}
