//
//  CCabCancelRequestViewController.swift
//  MapKitReuse
//
//  Created by Aravind on 29/09/18.
//  Copyright © 2018 Aravind. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase
class CCabCancelRequestViewController: CCabBaseViewController, CLLocationManagerDelegate {

	@IBOutlet var shimmerViews: [UIView]!
	@IBOutlet weak var gradientAnimationView: UIView!
	@IBOutlet weak var cancelRequestButton: UIButton!
	@IBOutlet weak var checkingNearbyLabel: UILabel!
  var db: Firestore!
  var locationManager:CLLocationManager!
	override func viewDidLoad() {
		super.viewDidLoad()
    let settings = FirestoreSettings()
    Firestore.firestore().settings = settings
    // [END setup]
    db = Firestore.firestore()
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
			self.showAnimation()
		}
    self.setupLocationManager()
		self.setupData()
		self.setFontSizeAndColor()
	}
	// MARK: - Initialise data
	func setFontSizeAndColor() {
		self.checkingNearbyLabel.font = UIFont.systemFont(ofSize: 17.0)
    self.cancelRequestButton.layer.cornerRadius = 6
    self.cancelRequestButton.clipsToBounds = true
		self.cancelRequestButton.titleLabel?.font = UIFont.systemFont(ofSize: 17.0)
		self.cancelRequestButton.titleLabel?.textColor = UIColor.white
	}
	func setupData() {
		self.checkingNearbyLabel.text = "Finding your ride"
		self.cancelRequestButton.setTitle("Searching Rides...", for: .normal)
	}

  
  // Just call setupLocationManager() in didFinishLaunchingWithOption.
  func setupLocationManager(){
    let currentCoordinate = ["lat": 0.0, "lng": 0.0]
    locationManager = CLLocationManager()
    locationManager?.delegate = self
    self.locationManager?.requestAlwaysAuthorization()
    locationManager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    locationManager?.startUpdatingLocation()
    
  }
  
  // Below method will provide you current location.
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if let location = locations.last {
      locationManager?.stopMonitoringSignificantLocationChanges()
      let locationValue:CLLocationCoordinate2D = location.coordinate
      print("locations = \(locationValue)")
      let currentCoordinate = ["lat": locationValue.latitude, "lng": locationValue.longitude]
      locationManager?.stopUpdatingLocation()
    }
  }
  
  
  // Below Mehtod will print error if not able to update location.
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("Error")
  }
  

  func showAnimation() {
		gradientAnimationView.showGradientAnimation()
	}
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	// MARK: - @IBAction
	@IBAction func cancelRequestButtonAction(_ sender: Any) {
    //self.deleteDocument()
		
	}

  private func deleteDocument() {
    // [START delete_document]
    db.collection("Rides").document(globalRideReferenceId).delete() { err in
      if let err = err {
        print("Error removing document: \(err)")
      } else {
        self.navigationController?.popViewController(animated: true)
        print("Document successfully removed!")
      }
    }
    // [END delete_document]
  }

  
}
