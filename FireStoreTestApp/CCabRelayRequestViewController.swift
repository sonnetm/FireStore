//
//  CCabRelayRequestViewController.swift
//  MapKitReuse
//
//  Created by Aravind on 29/09/18.
//  Copyright © 2018 Aravind. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import Pulsator
import Alamofire
import Firebase
import Reachability

class CCabRelayRequestViewController: CCabBaseViewController, CLLocationManagerDelegate {
	var locationManager = CLLocationManager()
	@IBOutlet weak var image: UIImageView!
	@IBOutlet weak var mapView: GMSMapView!
	@IBOutlet weak var pulsatorView: UIView!
	@IBOutlet weak var retryView: UIView!
	@IBOutlet weak var cancelView: UIView!
	var currentRideOtp: String?
  var db: Firestore!
  var listener: ListenerRegistration!
	let reachabilityManager = Alamofire.NetworkReachabilityManager(host: "www.apple.com")
  //declare this property where it won't go out of scope relative to your listener
  let reachability = Reachability()!
	override func viewDidLoad() {
		super.viewDidLoad()
		//		mapView.camera = GMSCameraPosition.camera(withTarget: CCabUtilities.getDefaultLocationForMap(), zoom: 17)
		let pickupLocationLat = 10.7989
		let pickupLocationLong = 78.9090
		let camera = GMSCameraPosition.camera(withLatitude: pickupLocationLat, longitude: pickupLocationLong, zoom: 17.0)
		self.mapView?.animate(to: camera)
		//Location Manager code to fetch current location
		self.locationManager.delegate = self
		self.locationManager.startUpdatingLocation()
		mapView.settings.rotateGestures = false
		mapView.settings.tiltGestures = false
		mapView.settings.scrollGestures = false
    self.setBackButtonNavigationBar(title: "Request Cab", isBackButtonRequired: true, controller: self)
    self.addShadow()
	}
  
	func showRetryView() {
		self.retryView.isHidden = false
		self.cancelView.isHidden = true
		self.pulsatorView.isHidden = true
  }

	func hideRetryView() {
		retryView.isHidden = true
		cancelView.isHidden = false
		pulsatorView.isHidden = false
	}
  
	func stopAllAnimations() {
		retryView.isHidden = true
		cancelView.isHidden = true
		pulsatorView.isHidden = true
	}
  
	func retryRideRequest() {
		retryView.isHidden = true
		cancelView.isHidden = false
		pulsatorView.isHidden = false
	}
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	override func viewWillAppear(_ animated: Bool) {
    // [START setup]
    let settings = FirestoreSettings()
    Firestore.firestore().settings = settings
    settings.isPersistenceEnabled = true
    // [END setup]
    db = Firestore.firestore()
    self.listenDocumentWithMetadata()
    NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
    do{
      try reachability.startNotifier()
    }catch{
      self.listenDocumentWithMetadata()
      print("could not start reachability notifier")
    }
		self.hideRetryView()
		self.addPulsatorToView(viewPulsator: self.pulsatorView)
		self.navigationController?.isNavigationBarHidden = false
		UIApplication.shared.statusBarStyle = .default
	}
  
  override func viewWillDisappear(_ animated: Bool) {
    self.stopRidesCollectionListener()
    reachability.stopNotifier()
    NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: reachability)
  }
  
  @objc func reachabilityChanged(note: Notification) {
    
    let reachability = note.object as! Reachability
    
    switch reachability.connection {
    case .wifi:
      self.listenDocumentWithMetadata()
      print("Reachable via WiFi")
    case .cellular:
      self.listenDocumentWithMetadata()
      print("Reachable via Cellular")
    case .none:
      self.stopRidesCollectionListener()
      print("Network not reachable")
    }
  }
  
  func addPulsatorToView(viewPulsator: UIView) {
    let pulsator = Pulsator()
    pulsator.numPulse = 6
    pulsator.radius = 150
    pulsator.animationDuration = 3
    pulsator.backgroundColor = UIColor.backgroundFadedGrey().withAlphaComponent(0.9).cgColor
    viewPulsator.layer.addSublayer(pulsator)
    pulsator.position = CGPoint(x: viewPulsator.frame.size.width/2, y: viewPulsator.frame.size.height/2)
    pulsator.start()
  }
  
  
//  private func listenForVehicleStatusChange() {
//    // [START listen_for_users]
//    // Listen to a query on a collection.
//    //
//    // We will get a first snapshot with the initial results and a new
//    // snapshot each time there is a change in the results.
//    db.collection("Vehicles")
//      .whereField("rideStatus", isEqualTo: "Ride Completed")
//      .addSnapshotListener { querySnapshot, error in
//        guard let snapshot = querySnapshot else {
//          print("Error retreiving snapshots \(error!)")
//          return
//        }
//        print("Current Vehicles rideStatus is Ride Completed: \(snapshot.documents.map { $0.data() })")
//    }
//    // [END listen_for_users]
//  }
  
  
  
//  private func listenDocument() {
//    // [START listen_document]
//    db.collection("Vehicles").document("1174647404")
//      .addSnapshotListener { documentSnapshot, error in
//        guard let document = documentSnapshot else {
//          print("Error fetching document: \(error!)")
//          return
//        }
//        guard let data = document.data() else {
//          print("Document data was empty.")
//          return
//        }
//        print("Current data: \(data)")
//        if let rideStatus: String = data["rideStatus"] as? String {
//          if(rideStatus == "Ride Completed") {
//            if(rideStatus == "Booking Accepted") {
//              if let vehicleId: String = data["vehicleId"] as? String {
//                self.moveToOnRideViewController(vehicleId: vehicleId)
//              }
//            }
//          }
//        }
//    }
//    // [END listen_document]
//  }
  
  func moveToOnRideViewController(vehicleId:String, rideStatus: String) {
    if let moveToRelayRequest = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "OnRideViewController") as? OnRideViewController {
      moveToRelayRequest.vehicleId = vehicleId
      self.navigationController?.pushViewController(moveToRelayRequest, animated: true)
    }
  }

  
//  private func listenDocumentLocal() {
//    // [START listen_document_local]
//    db.collection("Vehicles").document("1174647404")
//      .addSnapshotListener { documentSnapshot, error in
//        guard let document = documentSnapshot else {
//          print("Error fetching document: \(error!)")
//          return
//        }
//        let source = document.metadata.hasPendingWrites ? "Local" : "Server"
//        print("\(source) data: \(document.data() ?? [:])")
//    }
//    // [END listen_document_local]
//  }
  
//  private func listenWithMetadata() {
//    // [START listen_with_metadata]
//    // Listen to document metadata.
//    db.collection("Vehicles").document("1174647404")
//      .addSnapshotListener(includeMetadataChanges: true) { documentSnapshot, error in
//        // ...
//    }
//    // [END listen_with_metadata]
//  }
  
  private func listenDocumentWithMetadata() {
    // [START listen_document_local]
    self.stopRidesCollectionListener()
     listener = db.collection("Rides").document(globalRideReferenceId)
      .addSnapshotListener(includeMetadataChanges: true) { documentSnapshot, error in
        guard let document = documentSnapshot else {
          print("Error fetching document: \(error!)")
          return
        }
        if !document.metadata.isFromCache {
        guard let data = document.data() else {
          print("Document data was empty.")
          return
        }
        print("Current data: \(data)")
        if let rideStatus: String = data["rideStatus"] as? String {
          if(rideStatus == AppSyncRideStatus.accepted.statusValue || rideStatus == AppSyncRideStatus.driverArrived.statusValue || rideStatus == AppSyncRideStatus.onride.statusValue || rideStatus == AppSyncRideStatus.endRide.statusValue || rideStatus == AppSyncRideStatus.paymentCollected.statusValue || rideStatus == AppSyncRideStatus.rideCompleted.statusValue) {
            if let vehicleId: String = data["vehicleId"] as? String {
              self.moveToOnRideViewController(vehicleId: vehicleId, rideStatus: rideStatus)
            }
          }
        }
        }
    }
    // [END listen_document_local]
  }
  
 
  private func stopRidesCollectionListener() {
    // Stop listening to changes
    if listener != nil {
    listener.remove()
    }
  }
  
  
	// MARK: - Location Manager delegates
	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		if CLLocationManager.locationServicesEnabled() {
			switch CLLocationManager.authorizationStatus() {
      case .notDetermined, .restricted, .denied: break
			case .authorizedAlways, .authorizedWhenInUse:
				manager.startUpdatingLocation()
			}
		} else {
		}
	}
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		let location = locations.last
		//Finally stop updating location otherwise it will come again and again in this delegate
		self.locationManager.stopUpdatingLocation()
	}
}
