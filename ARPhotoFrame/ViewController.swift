//
//  ViewController.swift
//  ARPhotoFrame
//
//  Created by Alex Shevlyakov on 10/08/2018.
//  Copyright © 2018 Alex Shevlyakov. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import Foundation

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    // Create video player
    let videoPlayer: AVPlayer = {
        // Load cat video from bundle
        guard let url = Bundle.main.url(forResource: "nyan-cat", withExtension: "mp4", subdirectory: "art.scnassets") else {
            print("Could not find video file")
            return AVPlayer()
        }
        
        let player = AVPlayer(url: url)
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: nil) { notification in
            player.seek(to: CMTime.zero)
            player.play()
        }
        return player
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Set the scene to the view
        sceneView.scene = SCNScene()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARImageTrackingConfiguration()
        
        // Load images from asset catalog
        guard let trackingImages = ARReferenceImage.referenceImages(inGroupNamed: "Photos", bundle: Bundle.main) else {
            print("Could not load images")
            return
        }
        
        // Setup configuration
        configuration.trackingImages = trackingImages
        configuration.maximumNumberOfTrackedImages = 1
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // MARK: - ARSCNViewDelegate
    
    
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
        
        // Show video overlayed to image
        if let imageAnchor = anchor as? ARImageAnchor {
            
            // Create a plane
            let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width,
                                 height: imageAnchor.referenceImage.physicalSize.height)
            
            // Set AVPlayer as the plane's texture and play
            plane.firstMaterial?.diffuse.contents = self.videoPlayer
            self.videoPlayer.play()
            
            let playNode = SCNNode(geometry: plane)
            
            // Rotate the plane to match the anchor
            playNode.eulerAngles.x = -.pi / 2
            
            // Add plane node to parent
            node.addChildNode(playNode)
        }
        
        return node
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
}
