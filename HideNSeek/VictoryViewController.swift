//
//  VictoryViewController.swift
//  HideNSeek
//
//  Created by Projet2A on 16/05/2018.
//  Copyright © 2018 Projet2A. All rights reserved.
//

import UIKit

class VictoryViewController: UIViewController {

    
    @IBOutlet weak var label: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        label.text = ""
        players.sort(by: {$0.score < $1.score})
        for player in players {
            label.text?.append("\(player.name) \t \(player.score / 60) m \(player.score % 60) s \n")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
