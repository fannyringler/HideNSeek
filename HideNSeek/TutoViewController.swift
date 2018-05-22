//
//  TutoViewController.swift
//  HideNSeek
//
//  Created by Projet2A on 22/05/2018.
//  Copyright © 2018 Projet2A. All rights reserved.
//

import UIKit

class TutoViewController: UIViewController {
    
    var imageToShow = 1
    var textToShow : [String] = ["Choisissez le nombre de personnes qui vont chercher l'/ les objet(s)","Vous pouvez donner un nom à chaque chercheur","Cliquez sur \"Suivant\" pour valider","Lorsque qu'un carré partiel apparait, vous pouvez déposer un objet dessus","Si le carré est entier, la zone est optimale","Cliquez sur l'écran pour ajouter un objet\n Appuyez sur \"Cache\" pour valider","Donner le jeu au joueur indiqué\n Le joueur devra appuyer sur \"C'est parti !\" pour jouer","Déplacez vous pour trouver les objets cachés","Cliquez sur l'objet pour signaler que vous l'avez trouvé","Quand tous les joueurs ont fini de trouver tous les objets, le classement s'affiche !"]

    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var text: UITextView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageToShow = 1
        backButton.isHidden = true
        image?.image = UIImage(named: "Tuto1")
        text.text = "Choisissez le nombre de personnes qui vont chercher l'/ les objet(s)"
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onNext(_ sender: Any) {
        imageToShow += 1
        if imageToShow <= textToShow.count {
            image?.image = UIImage(named: "Tuto\(imageToShow)")
            text.text = textToShow[imageToShow - 1]
            backButton.isHidden = false
            if imageToShow == textToShow.count {
                nextButton.setTitle("Jouer", for: .normal)
            }
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "multiplayer")as! MultiplayerViewController
            self.present(viewController, animated: true, completion: nil)
        }
    }
    
    @IBAction func onBack(_ sender: Any) {
        imageToShow -= 1
        if imageToShow > 0 {
            image?.image = UIImage(named: "Tuto\(imageToShow)")
            text.text = textToShow[imageToShow - 1]
            if imageToShow == 1 {
                backButton.isHidden = true
            }
        }
    }
    
    
}
