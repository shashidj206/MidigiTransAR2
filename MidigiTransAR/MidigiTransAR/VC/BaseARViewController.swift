//
//  BaseARViewController.swift
//  MidigiTransAR
//
//  Created by Shashidhar Jagatap on 03/03/24.
//

import UIKit
import ARKit

class BaseARViewController: UIViewController {
    // Container view to hold ARSCNViewController's view
    @IBOutlet weak var containerView: UIView!
    @IBOutlet var scanFloorView: UIView!
    @IBOutlet var backButton: UIButton!
    @IBOutlet var newScanButton: UIButton!
    @IBOutlet var galleryButton: UIButton!
    
    var collectionVC: ARCollectionList?
    var isImageSelected = false
    var isCollectionViewVisible = false
    
    // Instance of ARSCNViewController
    var arSceneViewController: ARSCNViewController?
    var viewModel = ARSCNViewModel()
    
    // Add a new UIViewController
    func addChildViewController(newViewController: ARCollectionList) {
        // Check if the new view controller already has a parent view controller
        guard newViewController.parent == nil else {
            return // Do nothing if the view controller already has a parent
        }
        
        self.collectionVC = newViewController
        self.collectionVC?.viewModel = self.viewModel
        self.collectionVC?.delegate = self
        
        let buttonFrame = self.galleryButton?.frame ?? CGRect.zero
        
        self.collectionVC?.modalPresentationStyle = .popover
        
        // Present popover
        if let popoverPresentationController = self.collectionVC?.popoverPresentationController {
            // Set the permitted arrow directions
            popoverPresentationController.permittedArrowDirections = .up
            
            // Set the source view and adjust source rect based on the button frame
            popoverPresentationController.sourceView = self.view
            popoverPresentationController.sourceRect = CGRect(
                x: self.galleryButton.frame.origin.x,
                y: self.galleryButton.frame.origin.y + self.galleryButton.frame.size.height,
                width: self.galleryButton.frame.size.width,
                height: 0 // Set initial height to 0
            )
            
            // Present the popover controller
            if let popoverController = self.collectionVC {
                // Adjust the preferred content size of the popover controller
                popoverController.preferredContentSize = CGSize(width: self.view.frame.size.width * 0.7, height: self.view.frame.size.height - 40.0)
                present(popoverController, animated: true, completion: nil)
            }
        }
    }
    
    // Remove the currently added UIViewController
    func removeChildViewController() {
        self.collectionVC?.willMove(toParent: nil)
        self.collectionVC?.view.removeFromSuperview()
        self.collectionVC?.removeFromParent()
        self.collectionVC = nil
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if let vc = self.collectionVC {
            self.dismiss(animated: true)
        }
    }
    
    // Method to add ARSCNViewController to the container view
    func addARSceneViewController() {
        if let vc = self.storyboard?.instantiateViewController(identifier: "ARSCNViewController") as? ARSCNViewController {
            self.arSceneViewController = vc
            self.arSceneViewController?.viewModel = self.viewModel
            addChild(arSceneViewController!)
            containerView.addSubview(arSceneViewController!.view)
            arSceneViewController!.view.frame = containerView.bounds
            arSceneViewController!.didMove(toParent: self)
        }
        
    }
    
    @IBAction func openGalleryAction(_ sender: Any) {
        if let vc = self.storyboard?.instantiateViewController(identifier: "ARCollectionList") as? ARCollectionList {
            self.addChildViewController(newViewController: vc)
        }
        
        //self.openGallery()
    }
    
    @IBAction func newScanAction(_ sender: Any) {
        self.addARSceneViewController()
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.scanFloorView.isHidden = false
        self.arSceneViewController?.removeFromParent()
        self.arSceneViewController = nil
    }
    
    @IBAction func scanfloorAction(_ sender: Any) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            // Camera access already granted
            DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                self.scanFloorView.isHidden = true
                self.newScanButton.isHidden = false
                self.galleryButton.isHidden = false
                self.addARSceneViewController()
            })
            break
        case .notDetermined:
            // Request camera access
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    // Camera access granted
                    DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                        self.scanFloorView.isHidden = true
                        self.newScanButton.isHidden = false
                        self.galleryButton.isHidden = false
                        self.addARSceneViewController()
                    })
                } else {
                    // Camera access denied
                    DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                        self.scanFloorView.isHidden = false
                        self.newScanButton.isHidden = true
                        self.galleryButton.isHidden = true
                        self.showCameraPermissionAlert()
                    })
                }
            }
        case .denied, .restricted:
            // Camera access denied or restricted
            DispatchQueue.main.async{
                self.showCameraPermissionAlert()
            }
            break
        @unknown default:
            break
        }
    }
    
    private func showCameraPermissionAlert() {
        let alert = UIAlertController(
            title: "Camera Access Denied",
            message: "Please enable camera access in Settings to use this feature.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        })
        
        present(alert, animated: true, completion: nil)
    }
}

extension BaseARViewController:ARCollectionListDelegate{
    func setSelectedImage(image: UIImage) {
        isImageSelected = true
        isCollectionViewVisible = false
        self.dismiss(animated: true)
        // Update the material of the plane node with the selected image
        arSceneViewController?.setSelectedImage(image: image)
    }
}

extension BaseARViewController: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        
    }
    
    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        return true
    }
}

