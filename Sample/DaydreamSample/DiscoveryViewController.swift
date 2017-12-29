//
//  DiscoveryViewController.swift
//  DaydreamSample
//
//  Created by Sachin on 2/2/17.
//  Copyright © 2017 Daydream. All rights reserved.
//

import UIKit

class DiscoveryViewController: UIViewController {
	fileprivate let titleLabel: UILabel
	fileprivate let subtitleLabel: UILabel
	fileprivate var sampleViewController: SampleViewController? = nil
    fileprivate let connectionManager: DDConnectionManager = DDConnectionManager()
	
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		titleLabel = UILabel()
		subtitleLabel = UILabel()
		
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		
		// Add a basic title label
		titleLabel.font = UIFont.systemFont(ofSize: 30.0, weight: UIFontWeightMedium)
		titleLabel.textAlignment = .center
		view.addSubview(titleLabel)
		titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50).isActive = true
		titleLabel.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -50).isActive = true
		titleLabel.heightAnchor.constraint(equalToConstant: 80).isActive = true
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		
		// Add a subtitle label
		subtitleLabel.font = UIFont.systemFont(ofSize: 18.0, weight: UIFontWeightRegular)
		subtitleLabel.textAlignment = .center
		subtitleLabel.numberOfLines = 0
		view.addSubview(subtitleLabel)
		subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		subtitleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 50).isActive = true
		subtitleLabel.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -50).isActive = true
		subtitleLabel.heightAnchor.constraint(equalToConstant: 80).isActive = true
		subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
		
		titleLabel.text = "Looking for controllers..."
		subtitleLabel.text = "Ensure Bluetooth is on, then make your Daydream View controller discoverable by pressing the bottom button."
        
        connectionManager.delegate = self
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		discoverControllers()
	}
	
	func discoverControllers() {
		do {
			try connectionManager.startDaydreamControllerDiscovery()
		} catch DDControllerError.bluetoothOff {
			print("Bluetooth is off.")
		} catch _ {}
	}
}

extension DiscoveryViewController: DDConnectionManagerDelegate {
    func didConnect(to controller: DDController) {
        if nil == sampleViewController {
            sampleViewController = SampleViewController()
            sampleViewController?.controller = controller
        }
        sampleViewController!.modalTransitionStyle = .crossDissolve
        sampleViewController!.modalPresentationStyle = .overCurrentContext
        present(sampleViewController!, animated: true, completion: nil)
    }
    
    func didDisconnect(from controller: DDController) {
        dismiss(animated: true) { [weak self] in
            self!.sampleViewController = nil
            self!.discoverControllers()
        }
    }
}
