//
//  SelectViewController.swift
//  Pogger
//
//  Created by natsuyama on 2016/10/05.
//  Copyright © 2016年 Taiju Aoki. All rights reserved.
//

import UIKit

class SelectViewController: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource {

    var sendValue = 1
    var array = ["１日前","2日前","3日前","１週間前","1か月","3か月","半年前","１年前"]

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func didTapCloseButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let mapViewController = segue.destination as! MapViewController
        mapViewController.receiveValue = sendValue
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return array.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return array[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch row {
        case 0:
            return sendValue = 1
        case 1:
            return sendValue = 2
        case 2:
            return sendValue = 3
        case 3:
            return sendValue = 7
        case 4:
            return sendValue = 30
        case 5:
            return sendValue = 90
        case 6:
            return sendValue = 182
        case 7:
            return sendValue = 365
        default: break
        }
    }
}
