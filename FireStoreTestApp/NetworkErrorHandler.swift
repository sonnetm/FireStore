//
//  NetworkErrorHandler.swift
//  vanpool-passenger-ios
//
//  Created by Akhil on 7/13/18.
//

import Foundation
import UIKit

class NetworkErrorHandler {

  /// To get the proper error message corresponding to error status.
  ///
  /// - Parameter errorCode: HTTP Error code
  /// - Returns: Error message corresponding to error status.
  class func getErrorMessage(witherrorCode errorCode: Int?) -> String {

    switch errorCode ?? 0 {

    case 300...399:
      return NetworkResponse.redirection.errorMessage

    case 400:
      return NetworkResponse.badRequest.errorMessage

    case 401:
      return NetworkResponse.authenticationFailed.errorMessage

    case 402...499:
      return NetworkResponse.clientSideError.errorMessage

    case 500...599:
      return NetworkResponse.serverSideError.errorMessage

    case 1001:
      return NetworkResponse.timeOut.errorMessage

    default:
      return "Something went wrong. Please try again"
    }
  }

  public enum NetworkResponse: String {
    /// Message for Redirection.
    case redirection = "NETWORK_ERROR_REDIRECTION"
    /// Message for Bad Request.
    case badRequest = "NETWORK_ERROR_BAD_REQUEST"
    /// Message for Authentication failed.
    case authenticationFailed = "NETWORK_ERROR_AUTHENTICATION"
    /// Message for Client side error.
    case clientSideError = "NETWORK_ERROR_CLIENT_SIDE"
    /// Message for Server side error.
    case serverSideError = "NETWORK_ERROR_SERVER_SIDE"
    /// Message for Request timeOut.
    case timeOut = "NETWORK_ERROR_REQUEST_TIMEOUT"

    var errorMessage: String {
      return self.rawValue.localized
    }
  }
}
