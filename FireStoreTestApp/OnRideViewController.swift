//
//  OnRideViewController.swift
//  FireStoreTestApp
//
//  Created by Rohit Kr on 25/04/19.
//  Copyright © 2019 Rohit Kr. All rights reserved.
//

import UIKit
import Firebase
import Reachability
import GoogleMaps
import GooglePlaces

enum FireBaseRideStatus: String {
  case none = "NONE"
  case new = "NEW"
  case bookingSent = "BOOKING_SENT"
  case accepted = "BOOKING_ACCEPTED"
  case cancelled = "CANCELLED"
  case driverArrived = "ARRIVED"
  case onride = "ON_RIDE"
  case endRide = "END_RIDE"
  case rideCompleted = "RIDE_COMPLETED"
  var statusValue: String {
    switch self {
    case .none:
      return "NONE"
    case .new:
      return "NEW"
    case .bookingSent:
      return "BOOKING SENT"
    case .accepted:
      return "BOOKING ACCEPTED"
    case .cancelled:
      return "CANCELLED"
    case .driverArrived:
      return "ARRIVED"
    case .onride:
      return "ON RIDE"
    case .endRide:
      return "END RIDE"
    case .rideCompleted:
      return "RIDE COMPLETED"
    }
  }
}
class OnRideViewController: CCabBaseViewController {
  @IBOutlet weak var mapView: GMSMapView!
  var db: Firestore!
  var vehicleId = "000"
  var rideStatus = AppSyncRideStatus.accepted.statusValue
  var listenerRidesNode: ListenerRegistration!
  let reachability = Reachability()!
  var listenerVehiclesNode: ListenerRegistration!
  var coordinatesArray: [[String:String]] = []
  var vehicleDataDictionary: [String : Any] = ["vehicleId": "000", "rideId": "000","coordinates": [["latitude":"000", "longitude":"000","rideStatus": AppSyncRideStatus.accepted.statusValue]]]
  var carMarker = GMSMarker()
  var prevCoordinate: CLLocationCoordinate2D?
  
  @IBOutlet weak var cancelRideButton: UIButton!
  @IBOutlet weak var latitudeLabel: UILabel!
  @IBOutlet weak var longitudeLabel: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.setBackButtonNavigationBar(title: rideStatus, isBackButtonRequired: false, controller: self)
    self.addShadow()
    initialMapSetUp()
    prevCoordinate = nil
    if(rideStatus == AppSyncRideStatus.accepted.statusValue || rideStatus == AppSyncRideStatus.driverArrived.statusValue || rideStatus == AppSyncRideStatus.otpVerified.statusValue) {
      self.cancelRideButton.isHidden = false
    }
    else if(rideStatus == AppSyncRideStatus.onride.statusValue) {
      self.cancelRideButton.isHidden = true
    }
    setupMarkers()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    // [START setup]
    let settings = FirestoreSettings()
    Firestore.firestore().settings = settings
    // [END setup]
    db = Firestore.firestore()
    NotificationCenter.default.addObserver(self, selector: #selector(applicationWillTerminate), name: UIApplication.willTerminateNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
    do{
      try reachability.startNotifier()
    }catch {
      self.listenRideStatusCollection()
      self.listenDriverCoordinates()
      print("could not start reachability notifier")
    }
  }
  
  @objc private func applicationWillTerminate() {
    // Do whatever you want, for example update your view.
    vehicleDataDictionary = ["vehicleId": vehicleId, "rideId": globalRideReferenceId,"rideStatus": self.rideStatus,"coordinates": coordinatesArray]
    self.writeString(toFile: vehicleDataDictionary)
  }
  
  @objc func reachabilityChanged(note: Notification) {
    
    let reachability = note.object as! Reachability
    
    switch reachability.connection {
    case .wifi:
      self.listenRideStatusCollection()
      self.listenDriverCoordinates()
      print("Reachable via WiFi")
    case .cellular:
      self.listenRideStatusCollection()
      self.listenDriverCoordinates()
      print("Reachable via Cellular")
    case .none:
      self.stopRidesCollectionListener()
      self.stopVehiclesCollectionListener()
      print("Network not reachable")
    }
  }
  
  func writeString(toFile dictionary:[String : Any]) {
    do {
      let jsonData = try JSONSerialization.data(withJSONObject: dictionary)
      let aString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)
      // Build the path, and create if needed.
      let filePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
      let timestamp = NSDate().timeIntervalSince1970
      let fileName = "\(timestamp).json"
      
      let fileAtPath = URL(fileURLWithPath: filePath).appendingPathComponent(fileName).path
      
      let fileManager = FileManager.default
      if fileManager.fileExists(atPath: fileAtPath) {
        print("FILE AVAILABLE")
      } else {
        FileManager.default.createFile(atPath: fileAtPath, contents: nil, attributes: nil)
      }
      //writing
      do {
        try aString?.write(toFile: fileAtPath, atomically: false, encoding: String.Encoding.utf8.rawValue)
      }
      catch let error {
        print(error.localizedDescription)
      }
    }
    catch let error {
      print(error.localizedDescription)
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    vehicleDataDictionary = ["vehicleId": vehicleId, "rideId": globalRideReferenceId,"rideStatus": self.rideStatus,"coordinates": coordinatesArray]
    self.writeString(toFile: vehicleDataDictionary)
    self.stopRidesCollectionListener()
    self.stopVehiclesCollectionListener()
    reachability.stopNotifier()
    NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: reachability)
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  private func listenRideStatusCollection() {
    // [START listen_document_local]
    self.stopRidesCollectionListener()
    listenerRidesNode = db.collection("Rides").document(globalRideReferenceId)
      .addSnapshotListener(includeMetadataChanges: true) { documentSnapshot, error in
        guard let document = documentSnapshot else {
          print("Error fetching document: \(error!)")
          return
        }
        if !document.metadata.isFromCache {
          guard let data = document.data() else {
            self.stopRidesCollectionListener()
            self.stopVehiclesCollectionListener()
            if self.rideStatus == AppSyncRideStatus.onride.statusValue ||  self.rideStatus == AppSyncRideStatus.endRide.statusValue ||  self.rideStatus == AppSyncRideStatus.paymentCollected.statusValue  {
              self.cancelRideButton.isHidden = true
              self.showRideCompletedAlert()
              //            self.rideCompletionLambda()
            }
            else {
              self.navigationController?.popToRootViewController(animated: true)
            }
            print("Document data was empty.")
            return
          }
          print("Current data: \(data)")
          if let rideStatus: String = data["rideStatus"] as? String {
            self.rideStatus = rideStatus
            if (rideStatus == AppSyncRideStatus.new.statusValue) {
              self.navigationController?.popViewController(animated: true)
            }
            else if(rideStatus == AppSyncRideStatus.accepted.statusValue || rideStatus == AppSyncRideStatus.driverArrived.statusValue || rideStatus == AppSyncRideStatus.otpVerified.statusValue) {
              self.cancelRideButton.isHidden = false
            }
            else if(rideStatus == AppSyncRideStatus.onride.statusValue) {
              self.cancelRideButton.isHidden = true
            }
            self.navigationItem.title = FireBaseRideStatus(rawValue: rideStatus)?.statusValue
            self.coordinatesArray.append(["latitude":self.latitudeLabel.text ?? "000","longitude":self.longitudeLabel.text ?? "000","rideStatus": self.rideStatus])
          }
        }
    }
    // [END listen_document_local]
  }
  
  private func listenDriverCoordinates() {
    // [START listen_document_local]
    self.stopVehiclesCollectionListener()
    listenerVehiclesNode = db.collection("VehicleLocations").document(vehicleId)
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
          if let latitude: String = data["latitude"] as? String, let longitude: String = data["longitude"] as? String {
            self.coordinatesArray.append(["latitude":latitude,"longitude":longitude,"rideStatus": self.rideStatus])
            self.latitudeLabel.text = "\(latitude)"
            self.longitudeLabel.text = "\(longitude)"
            let newCoordinate =  CLLocationCoordinate2DMake(Double(latitude) ?? 0.0,Double(longitude) ?? 0.0)
            if self.prevCoordinate == nil {
              self.prevCoordinate = newCoordinate
            }
            let bearing = Utility.getHeadingForDirection(fromCoordinate: self.prevCoordinate ?? newCoordinate, toCoordinate: newCoordinate)
            self.carMovementAction(self.carMarker, withOldCoordinate: self.prevCoordinate ?? newCoordinate, andNewCoordinate: newCoordinate, inMapview: self.mapView, withBearing: bearing)
            self.setupCamera(currentlat: latitude, currentLong: longitude)
            self.prevCoordinate = newCoordinate
          //self.carMarker.position = CLLocationCoordinate2DMake(Double(latitude) ?? 0.0, Double(longitude) ?? 0.0)
          }
        }
    }
    // [END listen_document_local]
  }
  
  //  func rideDocumentDeleteListener() {
  //    db.collection("Rides").document(CCabConstants.rideId)
  //      .addSnapshotListener { documentSnapshot, error in
  //        guard let document = documentSnapshot else {
  //          print("Error fetching document: \(error!)")
  //          return
  //        }
  //        guard let data = document.data() else {
  //          self.navigationController?.popToRootViewController(animated: true)
  //          print("Document data was empty.")
  //          return
  //        }
  //        print("Current data: \(data)")
  //    }
  //  }
  
  //  func deletionListener() {
  //   db.collection("Rides").document(CCabConstants.rideId) .collection("rideStatusCollection")
  //      .addSnapshotListener { querySnapshot, error in
  //        guard let snapshot = querySnapshot else {
  //          print("Error fetching snapshots: \(error!)")
  //          return
  //        }
  //        snapshot.documentChanges.forEach { diff in
  //          if (diff.type == .added) {
  //            print("New city: \(diff.document.data())")
  //          }
  //          if (diff.type == .modified) {
  //            print("Modified city: \(diff.document.data())")
  //          }
  //          if (diff.type == .removed) {
  //            print("Removed city: \(diff.document.data())")
  //          }
  //        }
  //    }
  //  }
  
  @IBAction func cancelButtonAction(_ sender: Any) {
    self.cancelRideFromPax()
    //self.deleteDocument()
  }
  
  //  private func deleteDocument() {
  //    // [START delete_document]
  //    db.collection("Vehicles").document("1174647404").delete() { err in
  //      if let err = err {
  //        print("Error removing document: \(err)")
  //      } else {
  //        print("Document successfully removed!")
  //      }
  //    }
  //    // [END delete_document]
  //  }
  
  func showRideCompletedAlert() {
    let alert = UIAlertController(title: "Ride Completed", message: "Your ride completed successfully.", preferredStyle: UIAlertController.Style.alert)
    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) { _ -> Void in
      // Put your code here
      //      self.deleteDocument()
      self.navigationController?.popToRootViewController(animated: true)
      alert.dismiss(animated: true, completion: nil)
    })
    self.present(alert, animated: true, completion: nil)
  }
  
  func cancelRideFromPax() {
    if Utility.isConnectedToInternet {
      Utility.startActivityIdicator()
      CityCabAPI.cancelRideFromPax(rideId: globalRideReferenceId,vehicleId: vehicleId) { (response, errorResponse, errorMessage)  in
        if errorMessage == nil && errorResponse == nil, let successResponse = response {
          print("API Success")
          let valueSuccess = successResponse as? Bool
          Utility.stopActivityIndicator()
        } else if errorMessage == nil && response == nil, let errorResponse = errorResponse as? ServerErrorResponse {
          self.toastMessage(errorResponse.value?.message ?? "", isKeyboardInView: true)
        } else {
          self.toastMessage(errorMessage ?? "", isKeyboardInView: true)
        }
        Utility.stopActivityIndicator()
      }
    } else {
      self.toastMessage("No network Connection", isKeyboardInView: true)
    }
  }
  
  private func stopRidesCollectionListener() {
    // Stop listening to changes
    if listenerRidesNode != nil {
      listenerRidesNode.remove()
    }
  }
  
  private func stopVehiclesCollectionListener() {
    // Stop listening to changes
    if listenerVehiclesNode != nil {
      listenerVehiclesNode.remove()
    }
  }
  
  // MARK: Fire Lamdba
  func rideCompletionLambda() {
    let paramDict: [String: Any] = ["rideId": globalRideReferenceId, "vehicleId": vehicleId]
    print(paramDict)
    LambdaInvokeManger.invokeLambdaForRoute(lambdaRoute: .completeRide, withParam: paramDict) { (data, error) in
      if error != nil {
        self.toastMessage(error ?? "", isKeyboardInView: false)
      } else {
        print("nearByData ---", data!)
        //        let dataValue = data as? String
        //        print("near by data--\(String(describing: dataValue))")
        //        if let data = dataValue?.data(using: String.Encoding.utf8) {
        self.cancelRideButton.isHidden = true
        self.showRideCompletedAlert()
        //        }
      }
    }
  }
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destination.
   // Pass the selected object to the new view controller.
   }
   */
  
}

extension OnRideViewController {
  func initialMapSetUp() {
    self.mapView?.isMyLocationEnabled = false
    //Location Manager code to fetch current location
    self.mapView.settings.myLocationButton = false
    mapView.settings.rotateGestures = false
    mapView.padding = UIEdgeInsets(top: 50, left: 0, bottom: 200, right: 16)
    mapView.setMinZoom(0, maxZoom: 17)
  }
  
  func setupCamera(currentlat: String, currentLong: String) {
    let camera = GMSCameraPosition.camera(withLatitude: Double(currentlat) ?? 0.0, longitude: Double(currentLong) ?? 0.0, zoom: 15.0)
    self.mapView.camera = camera
    self.mapView.animate(to: camera)
  }
  
  func setupMarkers() {
    carMarker.iconView = nil
    carMarker.icon = #imageLiteral(resourceName: "Car_on_map")
    carMarker.map = mapView
    carMarker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
    carMarker.rotation = CLLocationDirection(0)
  }
  
  func getHeadingForDirection(fromCoordinate: CLLocationCoordinate2D, toCoordinate: CLLocationCoordinate2D) -> Float {
    let fromLat = Double(fromCoordinate.latitude).degreesToRadians
    let fromLng = Double(fromCoordinate.longitude).degreesToRadians
    let toLat   = Double(toCoordinate.latitude).degreesToRadians
    let toLng   = Double(toCoordinate.longitude).degreesToRadians
    let degree = Float(atan2(sin(toLng-fromLng)*cos(toLat), cos(fromLat)*sin(toLat)-sin(fromLat)*cos(toLat)*cos(toLng-fromLng))).radiansToDegrees
    if degree >= 0 {
      return degree
    } else {
      return 360+degree
    }
  }
  
  //Call this function to move the car according to bearing and location coordinates.
  func carMovementAction(_ marker: GMSMarker, withOldCoordinate oldCoordinate: CLLocationCoordinate2D, andNewCoordinate newCoordinate: CLLocationCoordinate2D,
                         inMapview mapView: GMSMapView, withBearing newBearing: Float) {
    print("car moving action")
    marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
    let calBearing: Float = getHeadingForDirection(fromCoordinate: oldCoordinate, toCoordinate: newCoordinate)
    marker.rotation = CLLocationDegrees(calBearing)
    marker.position = oldCoordinate
    marker.isTappable = false
    CATransaction.begin()
    CATransaction.setValue(Float(2.0), forKey: kCATransactionAnimationDuration)
    CATransaction.setCompletionBlock({() -> Void in
      if newBearing != 0 {
        marker.rotation = CLLocationDegrees(calBearing)
      } else {
        marker.rotation = CLLocationDegrees(calBearing)
      }
    })
    marker.position = newCoordinate
    marker.map = mapView
    marker.rotation = CLLocationDegrees(calBearing)
    CATransaction.commit()
    let visibleRegion: GMSVisibleRegion = mapView.projection.visibleRegion()
    let bounds = GMSCoordinateBounds(coordinate: visibleRegion.nearLeft, coordinate: visibleRegion.farRight)
    if !bounds.contains(marker.position) {
      let updatedCamera = GMSCameraUpdate.setTarget(marker.position, zoom: mapView.camera.zoom)
      mapView.animate(with: updatedCamera)
    }
  }
}
