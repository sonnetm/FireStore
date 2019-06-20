//
//  GoCityAPI.swift
//  gocity-cab-dev
//
//  Created by Juhi on 01/10/18.
//

import Foundation
import Alamofire
import AlamofireObjectMapper
import ObjectMapper
import GoogleMaps

enum CityCab {
  case createRide
  case cancelRide
  case googleGeocode(Double,Double,String)
}

let cabAuthorizationToken: NSString = "Bearer "
var rideRequestId = ""
var vehicleMainId = ""
extension CityCab {

  public var baseURL: URL { return URL(string: "https://apidev.gocitykw.com")!}
  public var geoCodeBaseURL: URL { return URL(string: "https://maps.googleapis.com/maps/api")!}

  public var path: String {
    switch self {
    case .createRide:
      return "ride/api/firestore/ride"
    case .cancelRide:
      return "ride/api/firestore/paxcancel"
    case .googleGeocode(let lat, let lng, let key):
      return "/geocode/json?latlng=\(lat),\(lng)&key=\(key)"
    default :
      return ""
    }
  }
  
  public func url() -> String {
    print(self.baseURL.appendingPathComponent(self.path).absoluteString.removingPercentEncoding!)
    return self.baseURL.appendingPathComponent(self.path).absoluteString.removingPercentEncoding!
  }

  public func googleUrl() -> String {
    print(self.geoCodeBaseURL.appendingPathComponent(self.path).absoluteString.removingPercentEncoding!)
    return self.geoCodeBaseURL.appendingPathComponent(self.path).absoluteString.removingPercentEncoding!
  }
  
  public var headers: HTTPHeaders? {
    
    switch self {
    case .createRide:
      return ["RideId": rideRequestId]
    case .cancelRide:
      return ["RideId": rideRequestId,
              "vehicleId":vehicleMainId]
    default:
      return ["Content-Type": "application/json",
              "X-Client-Id": "pax_app_ios",
              "x-app-client-token": "5db89e7472f81a4ea6b7a73f7c6729f1",
              "X-Client-Secret": "secret" ]
    }
  }

  public var method: Alamofire.HTTPMethod {
    switch self {
    // Add the post requests here, separated by comma
    case .createRide, .cancelRide:
      return .post
    default:
      return .get
    }
  }

  public var parameterEncoding: ParameterEncoding {
    switch self {
    case .createRide:
      return JSONEncoding.default
    default:
      return JSONEncoding.default
    }
  }
}

class CityCabAPI {
   //This is standard Alamofire Request Builder
  class func request(route: CityCab, body: Parameters?) -> DataRequest {
      return Alamofire.request (route.url(),
                                method: route.method,
                                parameters: body,
                                encoding: route.parameterEncoding,
                                headers: route.headers)
  }

  class func requestGoogleService(route: CityCab, body: Parameters?) -> DataRequest {
      return Alamofire.request (route.googleUrl(),
                                method: route.method,
                                parameters: body,
                                encoding: route.parameterEncoding,
                                headers: nil)
  }
  
  // MARK: - ApiManager Base methods
  class func isApiCallSuccess(statusCode: Int?) -> (Int?) {
    if let code = statusCode {
      switch code {
      case 200..<299:
        return (CabResponseCode.success.code)
      case 400:
        return (CabResponseCode.validationError.code)
      case 401:
        return (CabResponseCode.unAutherisedAccess.code)
      case 403:
        return (CabResponseCode.forbidden.code)
      case 500:
        return (CabResponseCode.serverError.code)
      default: return (CabResponseCode.failure.code)
      }
    }
    return (CabResponseCode.failure.code)
  }
  
  // MARK: - CreateRide Post
  class func createRideFromPax(rideId: String, completionHandler: @escaping (AnyObject?, AnyObject?, _ error: String?) -> Void) {
    rideRequestId = rideId
    request(route: .createRide, body: nil).responseJSON(completionHandler: { (responseJson) in
      responseJson.result.ifSuccess {
        let responseCode = isApiCallSuccess(statusCode: responseJson.response?.statusCode)
        switch responseCode {
        case CabResponseCode.success.code:

          if let JsonDataValue = responseJson.result.value as? Bool, JsonDataValue == true {
            completionHandler(JsonDataValue as AnyObject, nil, nil)
          }
          else {
            let decoder = try? JSONDecoder().decode(ServerErrorResponse.self, from: responseJson.data!)
            completionHandler(nil, nil, decoder?.value?.message ?? "Something Went Wrong")
          }
//          let decoder = try? JSONDecoder().decode(RideResponseCode.self, from: responseJson.data!)
        case CabResponseCode.validationError.code,
             CabResponseCode.unAutherisedAccess.code,
             CabResponseCode.notFound.code,
             CabResponseCode.forbidden.code:
          let decoder = try? JSONDecoder().decode(ServerErrorResponse.self, from: responseJson.data!)
          completionHandler(nil, decoder, nil)
        case CabResponseCode.serverError.code:
          let decoder = try? JSONDecoder().decode(ServerErrorResponse.self, from: responseJson.data!)
          completionHandler(nil, nil, decoder?.value?.message ?? NetworkErrorHandler.getErrorMessage(witherrorCode: CabResponseCode.serverError.code))
        default:
          let decoder = try? JSONDecoder().decode(ServerErrorResponse.self, from: responseJson.data!)
          completionHandler(nil, nil, decoder?.value?.message ?? "Something Went Wrong")
        }
      }
      responseJson.result.ifFailure {
        print("In Error case")
        let errorMessage = responseJson.result.value ?? NetworkErrorHandler.getErrorMessage(witherrorCode: responseJson.response?.statusCode)
        completionHandler(nil, nil, errorMessage as? String)
      }
    })
  }

  // MARK: - CreateRide Post
  class func cancelRideFromPax(rideId: String, vehicleId: String, completionHandler: @escaping (AnyObject?, AnyObject?, _ error: String?) -> Void) {
    rideRequestId = rideId
    vehicleMainId = vehicleId
    request(route: .cancelRide, body: nil).responseJSON(completionHandler: { (responseJson) in
      responseJson.result.ifSuccess {
        let responseCode = isApiCallSuccess(statusCode: responseJson.response?.statusCode)
        switch responseCode {
        case CabResponseCode.success.code:
          
          if let JsonDataValue = responseJson.result.value as? Bool, JsonDataValue == true {
            completionHandler(JsonDataValue as AnyObject, nil, nil)
          }
          else {
            let decoder = try? JSONDecoder().decode(ServerErrorResponse.self, from: responseJson.data!)
            completionHandler(nil, nil, decoder?.value?.message ?? "")
          }
        //          let decoder = try? JSONDecoder().decode(RideResponseCode.self, from: responseJson.data!)
        case CabResponseCode.validationError.code,
             CabResponseCode.unAutherisedAccess.code,
             CabResponseCode.notFound.code,
             CabResponseCode.forbidden.code:
          let decoder = try? JSONDecoder().decode(ServerErrorResponse.self, from: responseJson.data!)
          completionHandler(nil, decoder, nil)
        case CabResponseCode.serverError.code:
          let decoder = try? JSONDecoder().decode(ServerErrorResponse.self, from: responseJson.data!)
          completionHandler(nil, nil, decoder?.value?.message ?? NetworkErrorHandler.getErrorMessage(witherrorCode: CabResponseCode.serverError.code))
        default:
          let decoder = try? JSONDecoder().decode(ServerErrorResponse.self, from: responseJson.data!)
          completionHandler(nil, nil, decoder?.value?.message ?? "")
        }
      }
      responseJson.result.ifFailure {
        print("In Error case")
        let errorMessage = responseJson.result.value ?? NetworkErrorHandler.getErrorMessage(witherrorCode: responseJson.response?.statusCode)
        completionHandler(nil, nil, errorMessage as? String)
      }
    })
  }
}
