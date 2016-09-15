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

        let nib = UINib(nibName: "ListViewHeader", bundle:nil)
        let view = nib.instantiate(withOwner: nil, options: nil).first as! ListViewHeader

        return view
    }
}
