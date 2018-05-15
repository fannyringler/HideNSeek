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

var time = 0

class ViewController: UIViewController, ARSCNViewDelegate {

    var hide : Bool = true
    var nodeModel:SCNNode!
    let nodeName = "shiba"
    var objectPosition : SCNVector3!
    var object : SCNNode!
    var timer = Timer()
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var hideButton: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideButton.setTitle("Cache", for: .normal)
        timerLabel.isHidden = true
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        //sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        sceneView.antialiasingMode = .multisampling4X
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
        let modelScene = SCNScene(named:
            "art.scnassets/shiba/shiba.dae")!
        
        nodeModel =  modelScene.rootNode.childNode(
            withName: nodeName, recursively: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
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
    
    // MARK: - ARSCNViewDelegate
    
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
                    node.removeFromParentNode()
                    return
                }
            }
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
                    hide = true
                    hideButton.isHidden = false
                    timer.invalidate()
                    timerLabel.isHidden = true
                    node.removeFromParentNode()
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let viewController = storyboard.instantiateViewController(withIdentifier: "victory")as! VictoryViewController
                    self.present(viewController, animated: true, completion: nil)
                    return
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
        if !hide {
            guard let pointOfView = sceneView.pointOfView else { return }
            let transform = pointOfView.transform
            let orientation = SCNVector3(-transform.m31, -transform.m32, transform.m33)
            let location = SCNVector3(transform.m41, transform.m42, transform.m43)
            let currentPositionOfCamera = SCNVector3(orientation.x + location.x, orientation.y + location.y, orientation.z + location.z)
            if objectPosition != nil {
                let distance = calculateDistance(from: objectPosition, to: currentPositionOfCamera)
                if distance < 1{
                    object.isHidden = false
                }else{
                    object.isHidden = true
                }
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if hide{
            objectPosition = SCNVector3Make(anchor.transform.columns.3.x,anchor.transform.columns.3.y,anchor.transform.columns.3.z)
            object = node
        }
        if !anchor.isKind(of: ARPlaneAnchor.self) {
            DispatchQueue.main.async {
                let modelClone = self.nodeModel.clone()
                modelClone.position = SCNVector3Zero
                // Add model as a child of the node
                node.addChildNode(modelClone)
                
            }
        }
        
    }
    
    @IBAction func onButtonClick(_ sender: Any) {
        if hide {
            hide = false
            hideButton.isHidden = true
            timerLabel.isHidden = false
            time = 0
            timerLabel.text = printTime()
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ViewController.updateTimer), userInfo: nil, repeats: true)
        }
        else{
            hide = true
            timerLabel.isHidden = true
        }
    }
    
    @objc func updateTimer(){
        time += 1
        timerLabel.text = printTime()
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
