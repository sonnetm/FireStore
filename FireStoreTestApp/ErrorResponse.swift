//
//  ErrorResponse.swift
//  gocity-cab-dev
//
//  Created by MAC on 03/10/18.
//

import Foundation
import ObjectMapper

enum CabResponseCode: Int {
  case success = 200
  case validationError = 400
  case serverError = 500
  case notFound = 404
  case unAutherisedAccess = 401
  case forbidden = 403
  case failure = 0

  var code: Int { return self.rawValue }
}

class ErrorResponse: Codable {
  var statusCode: Int?
  var messageCode: String?
  var message: String?
	private enum CodingKeys: String, CodingKey {
		case statusCode = "StatusCode"
		case messageCode = "MessageCode"
		case message = "Message"
	}

}

class ServerErrorResponse: Codable {
  var contentTypes: [String]?
  var declaredType: String?
  var value: ErrorResponse?
  var statusCode: Int?
  var formatters: [String]?

  private enum CodingKeys: String, CodingKey {
    case contentTypes = "ContentTypes"
    case declaredType = "DeclaredType"
    case value = "Value"
    case statusCode = "StatusCode"
    case formatters = "Formatters"
  }
}
