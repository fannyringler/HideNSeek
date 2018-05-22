//
//  MultiObjectViewController.swift
//  HideNSeek
//
//  Created by Projet2A on 18/05/2018.
//  Copyright © 2018 Projet2A. All rights reserved.
//

import UIKit

var objects = 1

class MultiObjectViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let object = ["1","2","3"]
    
    @IBOutlet weak var choiceObject: UIPickerView!
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return object.count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let text = object[row]
        let attribute = NSAttributedString(string: text, attributes: [NSAttributedStringKey.font:UIFont(name: "Georgia", size: 15.0)!,NSAttributedStringKey.foregroundColor:UIColor.white])
        return attribute
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        objects = Int(object[row])!
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        objects = 1
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }



}
