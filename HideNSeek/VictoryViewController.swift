//
//  VictoryViewController.swift
//  HideNSeek
//
//  Created by Projet2A on 15/05/2018.
//  Copyright © 2018 Projet2A. All rights reserved.
//

import UIKit

class VictoryViewController: UIViewController {

    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        label.text = "Bravo vous avez trouvé l'objet en \(time / 60) m \(time % 60) s"
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
