//
//  ViewController.swift
//  FireStoreTestApp
//
//  Created by Rohit Kr on 25/04/19.
//  Copyright © 2019 Rohit Kr. All rights reserved.
//

import UIKit
import Firebase
 var globalRideReferenceId = "000112233445566778899"
class ViewController: CCabBaseViewController, UITextFieldDelegate {
  
  var db: Firestore!
  @IBOutlet weak var rideIdTextField: UITextField!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // [START setup]
    let settings = FirestoreSettings()
    Firestore.firestore().settings = settings
    // [END setup]
    db = Firestore.firestore()
    self.setBackButtonNavigationBar(title: "Book A Cab", isBackButtonRequired: false, controller: self)
    self.addShadow()
    // Do any additional setup after loading the view, typically from a nib.
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    rideIdTextField.text = ""
  }
  
// Add Data is Used to create a document without even the name specified.
//  private func addDocumentWithoutNameSpecifiedFirst() {
//    // Add a new document with a generated ID
//    var ref: DocumentReference? = nil
//    ref = db.collection("Vehicles").addDocument(data: [
//      "rideStatus": "Booking Accepted",
//      "latitude": 10.1912,
//      "longitude": 48.5967
//    ]) { err in
//      if let err = err {
//        print("Error adding document: \(err)")
//      } else {
//        print("Document added with ID: \(ref!.documentID)")
//      }
//    }
//  }
  
//  private func addDocumentWithoutNameSpecifiedTwo() {
//    var ref: DocumentReference? = nil
//    // Add a second document with a generated ID.
//    ref = db.collection("Vehicles").addDocument(data: [
//      "rideStatus": "Driver Arriving",
//      "driverName": "Subhash",
//      "latitude": 10.1912,
//      "longitude": 48.9967
//    ]) { err in
//      if let err = err {
//        print("Error adding document: \(err)")
//      } else {
//        print("Document added with ID: \(ref!.documentID)")
//      }
//    }
//  }

//  private func getCollection() {
//    // [START get_collection]
//    db.collection("Vehicles").getDocuments() { (querySnapshot, err) in
//      if let err = err {
//        print("Error getting documents: \(err)")
//      } else {
//        for document in querySnapshot!.documents {
//          print("\(document.documentID) => \(document.data())")
//        }
//      }
//    }
//    // [END get_collection]
//  }
  
  @IBAction func boocCabButtonAction(_ sender: Any) {
    let trimmedString = self.rideIdTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
    if trimmedString != "" {
      globalRideReferenceId = self.rideIdTextField.text ?? "000"
    self.createRideFromPax()
    //self.addDocumentWithNameSpecified()
    //self.moveToRelayRequestViewController()
    }
    else {
      self.toastMessage("Please enter a ride reference id to continue", isKeyboardInView: true)
    }
  }
  
  func createRideFromPax() {
    if Utility.isConnectedToInternet {
      Utility.startActivityIdicator()
      CityCabAPI.createRideFromPax(rideId: globalRideReferenceId) { (response, errorResponse, errorMessage)  in
        if errorMessage == nil && errorResponse == nil, let successResponse = response {
          print("API Success")
         let valueSuccess = successResponse as? Bool
          self.moveToRelayRequestViewController()
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
  
  // Set Data is Used to create/Update a document by specifying the name of the document.
//  private func addDocumentWithNameSpecified() {
//    // [START set_document]
//    // Add a new document in collection "Vehicles"
//
//    db.collection("Vehicles").document("1174647404").setData([
//      "latitude": 10.1912,
//      "longitude": 48.9967,
//    ]) { err in
//      if let err = err {
//        print("Error writing document: \(err)")
//      } else {
//        print("Document successfully written!")
//        Firestore.firestore().document("Vehicles/1174647404/rideStatusCollection/rideCollectionMain").setData([
//          "RideStatus": "New"
//          ])
//        self.moveToRelayRequestViewController()
//      }
//    }
//    // [END set_document]
//  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
  func moveToRelayRequestViewController() {
    if let moveToRelayRequest = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "CCabRelayRequestViewController") as? CCabRelayRequestViewController {
      self.navigationController?.pushViewController(moveToRelayRequest, animated: true)
    }
  }
}

