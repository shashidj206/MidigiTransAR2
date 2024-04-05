//
//  ViewController.swift
//  MidigiTransAR
//
//  Created by Shashidhar Jagatap on 21/02/24.
//


import SceneKit
import UIKit
import ARKit

class ARSCNViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    var imageNode: SCNNode?
    var selectedImage = UIImage(named: "")
    var detectedPlanes = Set<ARAnchor>()
    
    var viewModel:ARSCNViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configeSceneSession()
        selectedImage = self.viewModel?.paginationData.first
        //self.setupUI()
    }
    
    func setSelectedImage(image: UIImage) {
        selectedImage = image
        // Update the material of the plane node with the selected image
        if let planeNode = imageNode {
            let material = SCNMaterial()
            material.diffuse.contents = selectedImage
            planeNode.geometry?.firstMaterial = material
        }
    }
    
    private func configeSceneSession(){
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        //sceneView.showsStatistics = true
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
        // Enable plane detection
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
        //self.newScanButton.isHidden = false
    }
}

// MARK: ARSCNViewDelegate
extension ARSCNViewController{
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        //        print("didAdd")
        //        print(detectedPlanes)
        //        print(anchor)
        
        // Check if the anchor is of type ARPlaneAnchor
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        self.sceneView.debugOptions = []
        
        // Check if this plane has already been detected
        if detectedPlanes.count > 0 {
            if let planeNode = imageNode {
                let material = SCNMaterial()
                material.diffuse.contents = selectedImage
                planeNode.geometry?.firstMaterial = material
            }
            return // Plane already detected and processed
        }
        // Add the plane anchor to the set of detected planes
        detectedPlanes.insert(planeAnchor)
        
        // Create a plane geometry with fixed size (10x10 feet)
        let planeGeometry = SCNPlane(width: 10.0, height: 10.0)//SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        
        // Create a material with the selected image
        let material = SCNMaterial()
        material.diffuse.contents = selectedImage
        
        // Apply the material to the plane geometry
        planeGeometry.materials = [material]
        
        // Create a node with the plane geometry
        let planeNode = SCNNode(geometry: planeGeometry)
        
        
        // Position the plane node based on the anchor
        let planeNodePositionY = Float(planeAnchor.extent.y) / 2 // Adjust this value as needed

        planeNode.position = SCNVector3(planeAnchor.center.x, planeNodePositionY, -planeAnchor.center.z)
        
        // Rotate the plane to match the orientation of the detected plane
        planeNode.eulerAngles.x = -.pi / 2
        
        // Add the plane node to the scene
        node.addChildNode(planeNode)
        
        // Set imageNode for future reference
        imageNode = planeNode
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        // Check if the updated plane is already detected
        if detectedPlanes.count > 0 {
            if let planeNode = imageNode {
                let material = SCNMaterial()
                material.diffuse.contents = selectedImage
                planeNode.geometry?.firstMaterial = material
            }
            return // Plane already detected and processed
        }
        
        // Add the plane anchor to the set of detected planes
        detectedPlanes.insert(planeAnchor)
        
        // Create a plane geometry with fixed size (10x10 feet)
        let planeGeometry = SCNPlane(width: 10.0, height: 10.0)
        
        // Create a material with the selected image
        let material = SCNMaterial()
        material.diffuse.contents = selectedImage
        
        // Apply the material to the plane geometry
        planeGeometry.materials = [material]
        
        // Create a node with the plane geometry
        let planeNode = SCNNode(geometry: planeGeometry)
        
        // Position the plane node based on the anchor
        let planeNodePositionY = Float(planeAnchor.extent.y) / 2 // Adjust this value as needed

        planeNode.position = SCNVector3(planeAnchor.center.x, planeNodePositionY, planeAnchor.center.z)
        
        // Rotate the plane to match the orientation of the detected plane
        planeNode.eulerAngles.x = -.pi / 2
        
        // Add the plane node to the scene
        node.addChildNode(planeNode)
        
        // Set imageNode for future reference
        imageNode = planeNode
    }
}

extension ARSCNViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}
