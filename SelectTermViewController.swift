//
//  SelectTermViewController.swift
//  Pogger
//
//  Created by natsuyama on 2016/10/05.
//  Copyright © 2016年 Taiju Aoki. All rights reserved.
//

import UIKit

protocol SelectTermViewControllerDelegate: class {
    func selectTermViewController(_ selectTermViewController: SelectTermViewController, selectTerm value: Int, title: String?)
}

class SelectTermViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    private var sendTermValue = 7
    private var selectTermTitle = "１週間"
    private var selectArray = ["１週間", "１か月", "３か月", "１年", "すべて"]
    weak var delegate: SelectTermViewControllerDelegate?

    @IBAction func didTapCloseButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func didTapSaveButton(_ sender: UIBarButtonItem) {
        delegate?.selectTermViewController(self, selectTerm: sendTermValue, title: selectTermTitle)
        self.dismiss(animated: true, completion: nil)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.default
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
            sendTermValue = 7
        case 1:
            sendTermValue = 30
        case 2:
            sendTermValue = 90
        case 3:
            sendTermValue = 365
        case 4:
            sendTermValue = 36500
        default:
            sendTermValue = 7
        }
        selectTermTitle = selectArray[row]
    }
}
