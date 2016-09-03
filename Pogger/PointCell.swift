//
//  PointCell.swift
//  Pogger
//
//  Created by Taiju Aoki on 2016/04/17.
//  Copyright © 2016年 Taiju Aoki. All rights reserved.
//

import UIKit

protocol PointCellDelegate: class {
    func pointCell(pointCell: PointCell, didTapFavButton select: Bool)
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
}