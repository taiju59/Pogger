//
//  SelectTermViewController.swift
//  Pogger
//
//  Created by natsuyama on 2016/10/05.
//  Copyright © 2016年 Taiju Aoki. All rights reserved.
//

import UIKit

protocol SelectTermViewControllerDelegate: class {
    func selectTermViewController(_ selectTermViewController: SelectTermViewController, didSelectTerm termValue: Int, title: String)
}

class SelectTermViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIBarPositioningDelegate {

    weak var delegate: SelectTermViewControllerDelegate?

    private var selectedRow = 0
    private var termsArray = [[String: AnyObject!]]()

    override func viewDidLoad() {
        super.viewDidLoad()
        let filePath = Bundle.main.path(forResource: "terms", ofType: "plist")!
        termsArray = NSArray(contentsOfFile: filePath) as! [[String: AnyObject]]
    }

    func position(for bar: UIBarPositioning) -> UIBarPosition {
        // NavigationBar の見た目を NavigationController 使用時と同じにする
        return .topAttached
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return termsArray.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return termsArray[row]["title"] as! String?
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedRow = row
    }

    @IBAction func didTapCancelButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func didTapSaveButton(_ sender: UIBarButtonItem) {
        let termValue = termsArray[selectedRow]["value"] as! Int
        let termTitle = termsArray[selectedRow]["title"] as! String
        delegate?.selectTermViewController(self, didSelectTerm: termValue, title: termTitle)
        dismiss(animated: true, completion: nil)
    }

}
