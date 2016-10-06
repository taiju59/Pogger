//
//  SelectTermViewController.swift
//  Pogger
//
//  Created by natsuyama on 2016/10/05.
//  Copyright © 2016年 Taiju Aoki. All rights reserved.
//

import UIKit

protocol SelectTermViewControllerDelegate: class {
    func selectTerm(_ selectTerm: SelectTermViewController, sendValue value: Int)
}

class SelectTermViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    private var sendValue = 7
    private var selectArray = ["１週間", "１か月", "３か月", "１年", "すべて"]
    weak var delegate: SelectTermViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func didTapCloseButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func didTapSaveButton(_ sender: UIBarButtonItem) {
        delegate?.selectTerm(self,sendValue: sendValue)
        self.dismiss(animated: true, completion: nil)
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return selectArray.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return selectArray[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch row {
        case 0:
            sendValue = 7
        case 1:
            sendValue = 30
        case 2:
            sendValue = 90
        case 3:
            sendValue = 365
        case 4:
            sendValue = 36500
        default: break
        }
    }
}
