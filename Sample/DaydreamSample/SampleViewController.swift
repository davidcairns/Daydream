//
//  SampleViewController.swift
//  DaydreamSample
//
//  Created by Sachin on 2/2/17.
//  Copyright © 2017 Daydream. All rights reserved.
//

import UIKit

// Convenience extension for drawing circular shape layers
private extension CAShapeLayer {
	convenience init(circleWithSize size: CGSize) {
		self.init()
		self.path = UIBezierPath(ovalIn: CGRect(x: -size.width / 2, y: -size.height / 2, width: size.width, height: size.height)).cgPath
	}
}

// Convenience extension with a custom app tint color
private extension UIColor {
    static let appTint = UIColor(red: 80.0 / 255.0, green: 227.0 / 255.0, blue: 194.0 / 255.0, alpha: 1.0)
}

class SampleViewController: UIViewController {
    fileprivate let containerView: UIView
    
	// Image views for the controller and volume buttons
	fileprivate let controllerImageView: UIImageView
	fileprivate let volumeUpImageView: UIImageView
	fileprivate let volumeDownImageView: UIImageView
	
	// Image view + constraints for showing the current touchpad point
	fileprivate let touchpadPointImageView: UIImageView
	fileprivate var touchpadPointLeftConstraint: NSLayoutConstraint?
	fileprivate var touchpadPointTopConstraint: NSLayoutConstraint?
	
	// Overlays to show selection state
	fileprivate let touchpadButtonOverlay: CAShapeLayer
	fileprivate let appButtonOverlay: CAShapeLayer
	fileprivate let homeButtonOverlay: CAShapeLayer
	fileprivate let volumeUpButtonOverlay: CAShapeLayer
	fileprivate let volumeDownButtonOverlay: CAShapeLayer
	
	// Keep track of the last point on the touchpad so that we can animate it correctly
	fileprivate var lastPoint = CGPoint.zero
	
	// Layout constants
	fileprivate let controllerSizeMultiplier: CGFloat = 0.4
	fileprivate let controllerHeightToWidthRatio: CGFloat = 3.0
	fileprivate let buttonToControllerRatio: CGFloat = 0.35
	fileprivate let volumeButtonToControllerRatio: CGFloat = 0.025
    
    fileprivate var homeQuaternion: Quaternion? = nil
	
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        containerView = UIView()
        containerView.backgroundColor = UIColor.red
        
		controllerImageView = UIImageView(image: #imageLiteral(resourceName: "Controller"))
		controllerImageView.contentMode = .scaleAspectFit
        controllerImageView.backgroundColor = UIColor.green
		
		volumeUpImageView = UIImageView(image: #imageLiteral(resourceName: "Volume Up"))
		volumeDownImageView = UIImageView(image: #imageLiteral(resourceName: "Volume Down"))
		
		touchpadPointImageView = UIImageView(image: #imageLiteral(resourceName: "Finger"))
		touchpadPointImageView.isHidden = true
		
		// Calculate button sizes
		let screenWidth = UIScreen.main.bounds.width
		let controllerWidth = screenWidth * controllerSizeMultiplier
		let buttonWidth = controllerWidth * buttonToControllerRatio
		let volumeButtonWidth = controllerWidth * volumeButtonToControllerRatio
		
		// Create all button overlays with the correct sizes
		touchpadButtonOverlay = CAShapeLayer(circleWithSize: CGSize(width: controllerWidth * 0.9, height: controllerWidth * 0.9))
		appButtonOverlay = CAShapeLayer(circleWithSize: CGSize(width: buttonWidth, height: buttonWidth))
		homeButtonOverlay = CAShapeLayer(circleWithSize: CGSize(width: buttonWidth, height: buttonWidth))
		volumeUpButtonOverlay = CAShapeLayer(circleWithSize: CGSize(width: volumeButtonWidth, height: volumeButtonWidth))
		volumeDownButtonOverlay = CAShapeLayer(circleWithSize: CGSize(width: volumeButtonWidth, height: volumeButtonWidth))
		
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		
		view.backgroundColor = UIColor.white
		setupOverlays()
		setupConstraints()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		// Position the button overlays correctly
		touchpadButtonOverlay.position = CGPoint(x: controllerImageView.bounds.width / 2, y: (controllerImageView.bounds.width / 2) - 3)
		appButtonOverlay.position = CGPoint(x: controllerImageView.bounds.width / 2, y: (controllerImageView.bounds.height * 0.42))
		homeButtonOverlay.position = CGPoint(x: controllerImageView.bounds.width / 2, y: (controllerImageView.bounds.height * 0.58))
	}

	override var prefersStatusBarHidden: Bool {
		return true
	}
	
	func showPress(layer: CAShapeLayer, pressed: Bool) {
		// Set the layer hidden based on the press state.
		// Disable and then re-enable CATransaction actions to avoid animating the layer.
		CATransaction.setDisableActions(true)
		layer.isHidden = !pressed
		CATransaction.setDisableActions(false)
	}
    
    
    var controller: DDController! = nil {
        didSet {
            guard let controller = controller else { return }
            controller.touchpad.pointChangedHandler = { (touchpad: DDControllerTouchpad, point: CGPoint) in
                let wasHidden = self.touchpadPointImageView.isHidden
                let shouldBeHidden = point.equalTo(CGPoint.zero)
                
                if !shouldBeHidden {
                    self.touchpadPointLeftConstraint?.constant = (point.x) * self.controllerImageView.bounds.width
                    self.touchpadPointTopConstraint?.constant = (point.y) * self.controllerImageView.bounds.width
                }
                
                if wasHidden != shouldBeHidden && !self.lastPoint.equalTo(CGPoint.zero) {
                    // Animate hiding and showing the indicator
                    let initialScale: CGFloat = wasHidden ? 1.15 : 1
                    self.touchpadPointImageView.isHidden = false
                    self.touchpadPointImageView.transform = CGAffineTransform(scaleX: initialScale, y: initialScale)
                    
                    UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseInOut, .beginFromCurrentState], animations: {
                        let newScale: CGFloat = shouldBeHidden ? 1.15 : 1.0
                        self.touchpadPointImageView.transform = CGAffineTransform(scaleX: newScale, y: newScale)
                        self.touchpadPointImageView.alpha = shouldBeHidden ? 0.0 : 1.0
                        
                    }, completion: { (done: Bool) in
                        self.touchpadPointImageView.transform = CGAffineTransform.identity
                        self.touchpadPointImageView.isHidden = shouldBeHidden
                    })
                } else {
                    // Animate the movement of the indicator
                    UIView.animate(withDuration: 0.1, delay: 0, options: [.beginFromCurrentState], animations: {
                        self.view.layoutIfNeeded()
                    }, completion: nil)
                }
                
                self.lastPoint = point
            }
            
            controller.touchpad.button.valueChangedHandler = { (button: DDControllerButton, pressed: Bool) in
                self.showPress(layer: self.touchpadButtonOverlay, pressed: pressed)
            }
            
            controller.appButton.valueChangedHandler = { (button: DDControllerButton, pressed: Bool) in
                self.showPress(layer: self.appButtonOverlay, pressed: pressed)
            }
            
            controller.homeButton.pressedChangedHandler = { (button: DDControllerButton, pressed: Bool) in
                self.showPress(layer: self.homeButtonOverlay, pressed: pressed)
                self.homeQuaternion = nil
            }
            
            controller.volumeUpButton.valueChangedHandler = { (button: DDControllerButton, pressed: Bool) in
                self.volumeUpImageView.image = !pressed ? #imageLiteral(resourceName: "Volume Up") : #imageLiteral(resourceName: "Volume Up Pressed")
            }
            
            controller.volumeDownButton.valueChangedHandler = { (button: DDControllerButton, pressed: Bool) in
                self.volumeDownImageView.image = !pressed ? #imageLiteral(resourceName: "Volume Down") : #imageLiteral(resourceName: "Volume Down Pressed")
            }
            
            controller.orientationChangedHandler = { (orientation) -> Void in
                if nil == self.homeQuaternion {
                    // Our "default" makes the graphic point directly "into" the screen.
                    let defaultQuaternion = QuaternionMakeFromAxisAngle(Vect3Make(1.0, 0.0, 0.0), -Double.pi / 2.0)
                    self.homeQuaternion = QuaternionTimesQuaternion(defaultQuaternion, QuaternionInverse(orientation))
                }
                let t = QuaternionTimesQuaternion(self.homeQuaternion!, orientation)
                self.containerView.layer.transform = CATransform3D.from(matrix: QuaternionGetMatrix(t))
            }
        }
    }
}

// MARK: - View Layout
extension SampleViewController {
	func setupOverlays() {
		let highlightColor = UIColor.appTint.withAlphaComponent(0.6)
		touchpadButtonOverlay.fillColor = highlightColor.cgColor
		appButtonOverlay.fillColor = highlightColor.cgColor
		homeButtonOverlay.fillColor = highlightColor.cgColor
		volumeUpButtonOverlay.fillColor = highlightColor.cgColor
		volumeDownButtonOverlay.fillColor = highlightColor.cgColor
	}
	
	func setupConstraints() {
        view.addSubview(containerView)
        containerView.addSubview(volumeUpImageView)
        containerView.addSubview(volumeDownImageView)
        containerView.addSubview(controllerImageView)
        containerView.addSubview(touchpadPointImageView)
        
		let screenWidth = UIScreen.main.bounds.width
		let controllerWidth = screenWidth * controllerSizeMultiplier
        
        containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        containerView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        controllerImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        controllerImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        controllerImageView.widthAnchor.constraint(equalToConstant: controllerWidth).isActive = true
        controllerImageView.heightAnchor.constraint(equalTo: controllerImageView.widthAnchor, multiplier: controllerHeightToWidthRatio).isActive = true
		controllerImageView.translatesAutoresizingMaskIntoConstraints = false
		
		volumeUpImageView.centerXAnchor.constraint(equalTo: controllerImageView.rightAnchor).isActive = true
		volumeUpImageView.topAnchor.constraint(equalTo: controllerImageView.topAnchor, constant: 100).isActive = true
		volumeUpImageView.widthAnchor.constraint(equalToConstant: 7).isActive = true
		volumeUpImageView.heightAnchor.constraint(equalToConstant: 29).isActive = true
		volumeUpImageView.translatesAutoresizingMaskIntoConstraints = false
		
		volumeDownImageView.centerXAnchor.constraint(equalTo: volumeUpImageView.centerXAnchor).isActive = true
		volumeDownImageView.topAnchor.constraint(equalTo: volumeUpImageView.bottomAnchor, constant: 4).isActive = true
		volumeDownImageView.widthAnchor.constraint(equalToConstant: 7).isActive = true
		volumeDownImageView.heightAnchor.constraint(equalToConstant: 29).isActive = true
		volumeDownImageView.translatesAutoresizingMaskIntoConstraints = false
		
		touchpadPointLeftConstraint = touchpadPointImageView.centerXAnchor.constraint(equalTo: controllerImageView.leftAnchor, constant: 0)
		touchpadPointTopConstraint = touchpadPointImageView.centerYAnchor.constraint(equalTo: controllerImageView.topAnchor, constant: 0)
		touchpadPointImageView.widthAnchor.constraint(equalToConstant: 44).isActive = true
		touchpadPointImageView.heightAnchor.constraint(equalTo: touchpadPointImageView.widthAnchor).isActive = true
		touchpadPointImageView.translatesAutoresizingMaskIntoConstraints = false
		touchpadPointLeftConstraint?.isActive = true
		touchpadPointTopConstraint?.isActive = true
		
		touchpadButtonOverlay.isHidden = true
		appButtonOverlay.isHidden = true
		homeButtonOverlay.isHidden = true
		controllerImageView.layer.addSublayer(touchpadButtonOverlay)
		controllerImageView.layer.addSublayer(appButtonOverlay)
		controllerImageView.layer.addSublayer(homeButtonOverlay)
	}
}

extension CATransform3D {
    static func from(matrix m: Matrix3x3) -> CATransform3D {
        return CATransform3D(m11: CGFloat(m.m11), m12: CGFloat(m.m12), m13: CGFloat(m.m13), m14: CGFloat(m.m14),
                             m21: CGFloat(m.m21), m22: CGFloat(m.m22), m23: CGFloat(m.m23), m24: CGFloat(m.m24),
                             m31: CGFloat(m.m31), m32: CGFloat(m.m32), m33: CGFloat(m.m33), m34: CGFloat(m.m34),
                             m41: CGFloat(m.m41), m42: CGFloat(m.m42), m43: CGFloat(m.m43), m44: CGFloat(m.m44))
    }
}
