//
//  VictoryViewController.swift
//  HideNSeek
//
//  Created by Projet2A on 16/05/2018.
//  Copyright © 2018 Projet2A. All rights reserved.
//

import UIKit

class VictoryViewController: UIViewController {

    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        label.text = "Vous avez touvé l'objet en \(time / 60) m \(time % 60) s"
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
