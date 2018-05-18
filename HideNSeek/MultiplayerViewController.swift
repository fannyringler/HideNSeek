//
//  MultiplayerViewController.swift
//  HideNSeek
//
//  Created by Projet2A on 17/05/2018.
//  Copyright © 2018 Projet2A. All rights reserved.
//

import UIKit

class MultiplayerViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    let player = ["1","2","3","4"]
    var rows = 0
    
    @IBOutlet weak var choiceBox: UIPickerView!
    @IBOutlet weak var joueur1Label: UILabel!
    @IBOutlet weak var joueur1Name: UITextField!
    @IBOutlet weak var joueur2Label: UILabel!
    @IBOutlet weak var joueur2Name: UITextField!
    @IBOutlet weak var joueur3Label: UILabel!
    @IBOutlet weak var joueur3Name: UITextField!
    @IBOutlet weak var joueur4Label: UILabel!
    @IBOutlet weak var joueur4Name: UITextField!
    @IBOutlet weak var play: UIButton!
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        var text = player[row]
        let attribute = NSAttributedString(string: text, attributes: [NSAttributedStringKey.font:UIFont(name: "Georgia", size: 15.0)!,NSAttributedStringKey.foregroundColor:UIColor.white])
        return attribute
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        joueur1Label.isHidden = true
        joueur1Name.isHidden = true
        joueur2Label.isHidden = true
        joueur2Name.isHidden = true
        joueur3Label.isHidden = true
        joueur3Name.isHidden = true
        joueur4Label.isHidden = true
        joueur4Name.isHidden = true
        rows = Int(player[row])!
        if rows == 4 {
            joueur4Label.isHidden = false
            joueur4Name.isHidden = false
        }
        if rows >= 3 {
            joueur3Label.isHidden = false
            joueur3Name.isHidden = false
        }
        if rows >= 2{
            joueur2Label.isHidden = false
            joueur2Name.isHidden = false
        }
        if rows >= 1 {
            joueur1Label.isHidden = false
            joueur1Name.isHidden = false
            play.isHidden = false
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return player.count
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        joueur1Label.isHidden = true
        joueur1Name.isHidden = true
        joueur2Label.isHidden = true
        joueur2Name.isHidden = true
        joueur3Label.isHidden = true
        joueur3Name.isHidden = true
        joueur4Label.isHidden = true
        joueur4Name.isHidden = true
        play.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func play(_ sender: Any) {
        players.removeAll()
        if rows >= 1 {
            let player1 = Multiplayer()
            if joueur1Name.text != "" {
                player1.name = joueur1Name.text!
            }
            else {
                player1.name = "Joueur1"
            }
            players.append(player1)
        }
        if rows >= 2 {
            let player2 = Multiplayer()
            if joueur2Name.text != "" {
                player2.name = joueur2Name.text!
            }
            else {
                player2.name = "Joueur2"
            }
                players.append(player2)
            }
        if rows >= 3 {
            let player3 = Multiplayer()
            if joueur3Name.text != "" {
                player3.name = joueur3Name.text!
            }
            else {
                player3.name = "Joueur3"
            }
            players.append(player3)
        }
        if rows == 4 {
            let player4 = Multiplayer()
            if joueur4Name.text != "" {
                player4.name = joueur4Name.text!
            }
            else {
                player4.name = "Joueur4"
            }
            players.append(player4)
        }
    }
    

}
