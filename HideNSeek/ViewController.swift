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

class ViewController: UIViewController, ARSCNViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    var time = 0
    var hide : Bool = true
    var nodeModel:SCNNode!
    var nodeName = "candle"
    var objectPosition : [SCNVector3!] = []
    var object : [SCNNode!] = []
    let objectNames = ["candle", "chair", "cup", "lamp", "painting", "shiba", "stickyNote", "vase"]
    let objectName = ["Bougie", "Chaise", "Café", "Lampe", "Peinture", "Chien", "Post-it", "Vase"]
    var objectFind : [Bool] = []
    var timer = Timer()
    var sceneLight : SCNLight!
    var playerNext = 0
    var objectToHide = objects
    var objectToFind = objects
    var test : SCNNode!
    var modelScene = SCNScene()
    
    
    var focusSquare = FocusSquare()
    
    var session: ARSession {
        return sceneView.session
    }
    
    var screenCenter: CGPoint {
        let bounds = sceneView.bounds
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    @IBOutlet var sceneView: ARSCNView!

    @IBOutlet weak var objectAvailable: UIPickerView!
    @IBOutlet weak var readyView: UIView!
    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var readyPlayer: UILabel!
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
        objectAvailable.isHidden = false
        // Set the view's delegate
        sceneView.delegate = self
        
        // Set up scene content.
        setupCamera()
        sceneView.scene.rootNode.addChildNode(focusSquare)
        
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
       
        if nodeName == "shiba"{
            self.modelScene = SCNScene(named:
                "art.scnassets/shiba/shiba.dae")!
        }else{
            self.modelScene = SCNScene(named:
                "art.scnassets/\(nodeName)/\(nodeName).scn")!
        }
        
        nodeModel =  modelScene.rootNode.childNode(
            withName: nodeName, recursively: true)
    }
    
    func setupCamera() {
        guard let camera = sceneView.pointOfView?.camera else {
            fatalError("Expected a valid `pointOfView` from the scene.")
        }
        
        /*
         Enable HDR camera settings for the most realistic appearance
         with environmental lighting and physically based materials.
         */
        camera.wantsHDR = true
        camera.exposureOffset = -1
        camera.minimumExposure = -1
        camera.maximumExposure = 3
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Prevent the screen from being dimmed to avoid interuppting the AR experience.
        UIApplication.shared.isIdleTimerDisabled = true
        
        // Start the `ARSession`.
        resetTracking()

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
                    if let index = object.index(where: { $0 == node }) {
                        object.remove(at: index)
                        objectPosition.remove(at: index)
                    }
                    node.removeFromParentNode()
                    objectToHide += 1
                    return
                }
            }
            if objectToHide > 0 {
                let hitResultsFeaturePoints: [ARHitTestResult] =
                    sceneView.hitTest(screenCenter, types: .featurePoint)
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
            if let index = objectNames.index(where: { $0 == node.name }) {
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
            self.focusSquare.hide()
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
        }else{
            DispatchQueue.main.async {
                self.updateFocusSquare()
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
            objectAvailable.isHidden = true
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
    
    
    func updateFocusSquare() {
        // Perform hit testing only when ARKit tracking is in a good state.
        if let camera = session.currentFrame?.camera, case .normal = camera.trackingState,
            let result = self.smartHitTest(screenCenter) {
            DispatchQueue.main.async {
                self.focusSquare.unhide()
                self.sceneView.scene.rootNode.addChildNode(self.focusSquare)
                self.focusSquare.state = .detecting(hitTestResult: result, camera: camera)
            }
        } else {
            DispatchQueue.main.async {
                self.focusSquare.state = .initializing
                self.sceneView.pointOfView?.addChildNode(self.focusSquare)
                self.focusSquare.hide()
            }
        }
    }
    
    func resetTracking() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        configuration.isLightEstimationEnabled = true
        session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    // MARK: Position Testing
    func smartHitTest(_ point: CGPoint,
                      infinitePlane: Bool = false,
                      objectPosition: float3? = nil,
                      allowedAlignments: [ARPlaneAnchor.Alignment] = [.horizontal, .vertical]) -> ARHitTestResult? {
        
        // Perform the hit test.
        let results = sceneView.hitTest(point, types: [.existingPlaneUsingGeometry, .estimatedVerticalPlane, .estimatedHorizontalPlane])
        
        // 1. Check for a result on an existing plane using geometry.
        if let existingPlaneUsingGeometryResult = results.first(where: { $0.type == .existingPlaneUsingGeometry }),
            let planeAnchor = existingPlaneUsingGeometryResult.anchor as? ARPlaneAnchor, allowedAlignments.contains(planeAnchor.alignment) {
            return existingPlaneUsingGeometryResult
        }
        
        if infinitePlane {
            
            // 2. Check for a result on an existing plane, assuming its dimensions are infinite.
            //    Loop through all hits against infinite existing planes and either return the
            //    nearest one (vertical planes) or return the nearest one which is within 5 cm
            //    of the object's position.
            let infinitePlaneResults = sceneView.hitTest(point, types: .existingPlane)
            
            for infinitePlaneResult in infinitePlaneResults {
                if let planeAnchor = infinitePlaneResult.anchor as? ARPlaneAnchor, allowedAlignments.contains(planeAnchor.alignment) {
                    if planeAnchor.alignment == .vertical {
                        // Return the first vertical plane hit test result.
                        return infinitePlaneResult
                    } else {
                        // For horizontal planes we only want to return a hit test result
                        // if it is close to the current object's position.
                        if let objectY = objectPosition?.y {
                            let planeY = infinitePlaneResult.worldTransform.translation.y
                            if objectY > planeY - 0.05 && objectY < planeY + 0.05 {
                                return infinitePlaneResult
                            }
                        } else {
                            return infinitePlaneResult
                        }
                    }
                }
            }
        }
        
        // 3. As a final fallback, check for a result on estimated planes.
        let vResult = results.first(where: { $0.type == .estimatedVerticalPlane })
        let hResult = results.first(where: { $0.type == .estimatedHorizontalPlane })
        switch (allowedAlignments.contains(.horizontal), allowedAlignments.contains(.vertical)) {
        case (true, false):
            return hResult
        case (false, true):
            // Allow fallback to horizontal because we assume that objects meant for vertical placement
            // (like a picture) can always be placed on a horizontal surface, too.
            return vResult ?? hResult
        case (true, true):
            if hResult != nil && vResult != nil {
                return hResult!.distance < vResult!.distance ? hResult! : vResult!
            } else {
                return hResult ?? vResult
            }
        default:
            return nil
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return objectNames.count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        
        let text = objectName[row]
        
        let attribute = NSAttributedString(string: text, attributes: [NSAttributedStringKey.font:UIFont(name: "Georgia", size: 20.0)!,NSAttributedStringKey.foregroundColor:UIColor(red: 250/255, green: 128/255, blue: 114/255, alpha: 1)])
        return attribute
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.nodeName = objectNames[row]
        if nodeName == "shiba"{
            self.modelScene = SCNScene(named:
                "art.scnassets/shiba/shiba.dae")!
        }else{
            self.modelScene = SCNScene(named:
                "art.scnassets/\(nodeName)/\(nodeName).scn")!
        }
        
        nodeModel =  modelScene.rootNode.childNode(
            withName: nodeName, recursively: true)
    }
}
