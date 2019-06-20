//
//  CCabConstants.swift
//  gocity-cab-dev
//
//  Created by Rohit Kr on 12/09/18.
//

import Foundation

enum AppSyncRideStatus {
  case none
  case new
  case bookingSent
  case accepted
  case cancelled
  case driverArrived
  case otpVerified
  case driverArriving
  case onride
  case endRide
  case paymentCollected
  case rideCompleted
  var statusValue: String {
    switch self {
    case .none:
      return "NONE"
    case .new:
      return "NEW"
    case .bookingSent:
      return "BOOKING_SENT"
    case .accepted:
      return "BOOKING_ACCEPTED"
    case .cancelled:
      return "CANCELLED"
    case .driverArrived:
      return "ARRIVED"
    case .driverArriving:
      return "BOOKING_ACCEPTED"
    case .otpVerified:
      return "OTP_VERIFIED"
    case .onride:
      return "ON_RIDE"
    case .endRide:
      return "END_RIDE"
    case .paymentCollected:
      return "PYMT_COLLECTED"
    case .rideCompleted:
      return "RIDE_COMPLETED"
    }
  }
}
struct CCabConstants {
}
