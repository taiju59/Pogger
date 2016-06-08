//
//  ListViewHeader.swift
//  Pogger
//
//  Created by Taiju Aoki on 2016/04/23.
//  Copyright © 2016年 Taiju Aoki. All rights reserved.
//

import UIKit

class ListViewHeader: UIView {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    class func view() -> ListViewHeader {
        
        let nib = UINib(nibName: "ListViewHeader",  bundle:nil)
        let view = nib.instantiateWithOwner(nil, options: nil).first as! ListViewHeader
//        view.titleLabel.layoutMargins = UIEdgeInsets(top: 15, left: 20, bottom: 15, right: 20)

        return view
    }
}
