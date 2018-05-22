//
//  ViewController.swift
//  HideNSeek
//
//  Created by Projet2A on 14/05/2018.
//  Copyright © 2018 Projet2A. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

var players : [Multiplayer] = []

class ViewController: UIViewController, ARSCNViewDelegate {

    var time = 0
    var hide : Bool = true
    var nodeModel:SCNNode!
    let nodeName = "shiba"
    var objectPosition : [SCNVector3!] = []
    var object : [SCNNode!] = []
    var objectFind : [Bool] = []
    var timer = Timer()
    var sceneLight : SCNLight!
    var playerNext = 0
    var objectToHide = objects
    var objectToFind = objects
    var test : SCNNode!
    
    @IBOutlet weak var readyView: UIView!
    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var readyPlayer: UILabel!
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var hideButton: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var readySentence: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        objectToHide = objects
        errorLabel.text = ""
        errorLabel.isHidden = true
        hideButton.setTitle("Cache", for: .normal)
        timerLabel.isHidden = true
        readyView.isHidden = true
        goButton.isHidden = true
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        sceneView.autoenablesDefaultLighting = false
        //sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        sceneView.antialiasingMode = .multisampling4X
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
        sceneLight = SCNLight()
        sceneLight.type = .omni
        
        let lightNode = SCNNode()
        lightNode.light = sceneLight
        lightNode.position = SCNVector3(x:0 ,y:10 ,z:2)
        
        sceneView.scene.rootNode.addChildNode(lightNode)
        
        let modelScene = SCNScene(named:
            "art.scnassets/shiba/shiba.dae")!
        
        nodeModel =  modelScene.rootNode.childNode(
            withName: nodeName, recursively: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    
    func calculateDistance(from:SCNVector3,to:SCNVector3) -> Float{
        let x = from.x - to.x
        let y = from.y - to.y
        return sqrtf( (x * x) + (y * y))
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if hide {
            let location = touches.first!.location(in: sceneView)
            var hitTestOptions = [SCNHitTestOption: Any]()
            hitTestOptions[SCNHitTestOption.boundingBoxOnly] = true
            let hitResults: [SCNHitTestResult]  =
                sceneView.hitTest(location, options: hitTestOptions)
            if let hit = hitResults.first {
                if let node = getParent(hit.node) {
                    for i in 0...object.count - 1  {
                        if object[i] == node {
                            object.remove(at: i)
                            objectPosition.remove(at: i)
                        }
                    }
                    node.removeFromParentNode()
                    objectToHide += 1
                    return
                }
            }
            if objectToHide > 0 {
                let hitResultsFeaturePoints: [ARHitTestResult] =
                    sceneView.hitTest(location, types: .featurePoint)
                if let hit = hitResultsFeaturePoints.first {
                    // Get a transformation matrix with the euler angle of the camera
                    let rotate = simd_float4x4(SCNMatrix4MakeRotation(sceneView.session.currentFrame!.camera.eulerAngles.y, 0, 1, 0))
                    
                    // Combine both transformation matrices
                    let finalTransform = simd_mul(hit.worldTransform, rotate)
                    
                    // Use the resulting matrix to position the anchor
                    sceneView.session.add(anchor: ARAnchor(transform: finalTransform))
                    // sceneView.session.add(anchor: ARAnchor(transform: hit.worldTransform))
                    errorLabel.isHidden = true
                    objectToHide -= 1
                }
               
            }
            else {
                tooMuchObject()
            }
        }
        else{
            let location = touches.first!.location(in: sceneView)
            var hitTestOptions = [SCNHitTestOption: Any]()
            hitTestOptions[SCNHitTestOption.boundingBoxOnly] = true
            let hitResults: [SCNHitTestResult]  =
                sceneView.hitTest(location, options: hitTestOptions)
            if let hit = hitResults.first {
                if let node = getParent(hit.node) {
                    for i in 0...object.count - 1 {
                        if object[i] == node && objectFind[i] == false {
                            objectFind[i] = true
                            object[i].isHidden = true
                            objectToFind -= 1
                            if objectToFind > 0 {
                                return
                            }
                            timer.invalidate()
                            players[playerNext - 1].score = time
                            if playerNext == players.count {
                                hide = true
                                hideButton.isHidden = false
                                timerLabel.isHidden = true
                                objectToFind = objects
                                node.removeFromParentNode()
                                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                let viewController = storyboard.instantiateViewController(withIdentifier: "victory")as! VictoryViewController
                                self.present(viewController, animated: true, completion: nil)
                            }
                            else {
                                hideButton.isHidden = true
                                readyView.isHidden = false
                                goButton.isHidden = false
                                readyPlayer.text = "C'est au tour de \(players[playerNext].name)"
                                if playerNext < players.count {
                                    playerNext += 1
                                }
                                objectToFind = objects
                            }
                            return
                            
                        }
                    }
                }
            }
        }
    }
    
    func getParent(_ nodeFound: SCNNode?) -> SCNNode? {
        if let node = nodeFound {
            if node.name == nodeName {
                return node
            } else if let parent = node.parent {
                return getParent(parent)
            }
        }
        return nil
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if let estimate = self.sceneView.session.currentFrame?.lightEstimate {
            sceneLight.intensity = estimate.ambientIntensity
        }
        if !hide {
            guard let pointOfView = sceneView.pointOfView else { return }
            let transform = pointOfView.transform
            let orientation = SCNVector3(-transform.m31, -transform.m32, transform.m33)
            let location = SCNVector3(transform.m41, transform.m42, transform.m43)
            let currentPositionOfCamera = SCNVector3(orientation.x + location.x, orientation.y + location.y, orientation.z + location.z)
            for i in 0...object.count - 1 {
                if objectPosition[i] != nil {
                    if objectFind[i] == false {
                        let distance = calculateDistance(from: objectPosition[i], to: currentPositionOfCamera)
                        if distance < 1{
                            object[i].isHidden = false
                        }else{
                            object[i].isHidden = true
                        }
                    }
                }
            }
        }
       
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if !anchor.isKind(of: ARPlaneAnchor.self) {
            DispatchQueue.main.async {
                let modelClone = self.nodeModel.clone()
                modelClone.position = SCNVector3Zero
                // Add model as a child of the node
                node.addChildNode(modelClone)
                self.objectPosition.append(SCNVector3Make(anchor.transform.columns.3.x,anchor.transform.columns.3.y,anchor.transform.columns.3.z))
                self.object.append(modelClone)
                self.objectFind.append(false)
            }
        }

    }
    
    @IBAction func onButtonClick(_ sender: Any) {
        if object.count == 0 {
            zeroObject()
        }
        else if objectToHide > 0 {
            hideOneMore()
        }
        else {
            hide = false
            hideButton.isHidden = true
            readyView.isHidden = false
            goButton.isHidden = false
            readyPlayer.text = "C'est au tour de \(players[playerNext].name)"
            if objects > 1 {
                readySentence.text = "Etes-vous prêt à chercher \(objects) objets ?"
            } else {
                readySentence.text = "Etes-vous prêt à chercher l'objet ?"
            }
            if playerNext < players.count {
                playerNext += 1
            }
            errorLabel.isHidden = true
        }
    }
    
    func hideOneMore(){
        errorLabel.isHidden = false
        errorLabel.text = "Veuillez cacher un objet en plus"
    }
    
    @objc func updateTimer(){
        time += 1
        timerLabel.text = printTime()
    }
    
    @IBAction func go(_ sender: Any) {
        timerLabel.isHidden = false
        time = 0
        timerLabel.text = printTime()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ViewController.updateTimer), userInfo: nil, repeats: true)
        readyView.isHidden = true
        goButton.isHidden = true
        for i in 0...object.count - 1 {
            object[i].isHidden = false
            objectFind[i] = false
        }
    }
    
    func zeroObject() {
        errorLabel.isHidden = false
        errorLabel.text = "Veuillez cacher un objet"
    }
    
    func tooMuchObject() {
        errorLabel.isHidden = false
        errorLabel.text = "Vous avez caché assez d'objets"
    }
    
    func printTime() -> String {
        var minutes = "00"
        var seconds = "\(time)"
        if time >= 60 {
            if time / 60 < 10 {
                minutes = "0\(time / 60)"
            }
            else {
                minutes = "\(time / 60)"
            }
        }
        if time % 60 < 10{
            seconds = "0\(time % 60)"
        }
        else {
            seconds = "\(time % 60)"
        }
        return minutes + ":" + seconds
    }
    
}
