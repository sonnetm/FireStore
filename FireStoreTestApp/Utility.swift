//
//  Utility.swift
//  vanpool-passenger-ios
//

import Foundation
import UIKit
import Alamofire

var customActivityIndicator = UIActivityIndicatorView()
var tripHandler = UInt()
var statusHandler = UInt()
var promotionHandler = UInt()
var rideStatusHandler = UInt()
var estimateTimeHandler = UInt()
var distanceCoveredHandler = UInt()
var startTimeHandler = UInt()
var lastUpdatedHandler = UInt()

class Utility {

 /// To check the reachability status. Will return 'true' if network is reachable.
  class  var isConnectedToInternet: Bool {
    return NetworkReachabilityManager()!.isReachable
  }
  /// To start ActivityIndicator
  class func startActivityIdicator() {
    customActivityIndicator.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    customActivityIndicator.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5)
    customActivityIndicator.style = UIActivityIndicatorView.Style.whiteLarge
    customActivityIndicator.color = UIColor.white
    customActivityIndicator.hidesWhenStopped = true
    UIApplication.shared.delegate?.window!!.addSubview(customActivityIndicator)
    customActivityIndicator.startAnimating()
  }

  /// To stop ActivityIndicator
  class func stopActivityIndicator() {
    customActivityIndicator.stopAnimating()
    customActivityIndicator.removeFromSuperview()
  }
    class func getActivityIndicator() -> UIActivityIndicatorView {
        let customIndicator = UIActivityIndicatorView()
        customIndicator.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        customIndicator.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.2)
        customIndicator.style = UIActivityIndicatorView.Style.whiteLarge
        customIndicator.color = UIColor.gray
        customIndicator.hidesWhenStopped = true
        return customIndicator
    }
  /// To validate email id
  ///
  /// - Parameter email: email id
  /// - Returns: returns 'true' for valid email id
  class func isValidEmail(email: String) -> Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
    let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
    return emailTest.evaluate(with: email)  }

  /// To validate phone number
  ///
  /// - Parameter phone: phone number
  /// - Returns: returns 'true' for valid phone number
  class func isValidPhone(phone: String) -> Bool {
      do {
          let expression = "^\\d{8}(\\.\\d?)?$"
          let regex = try NSRegularExpression(pattern: expression, options: .caseInsensitive)
          let numberOfMatches = regex.numberOfMatches(in: phone, options: [], range: NSRange(location: 0, length: (phone.count)))
          return numberOfMatches > 0
      } catch let error {
          print(error)
          return false
      }
  }

  /// To validate civilId
  /// - Parameter civilId: CivilId
  /// - Returns: returns 'true' for valid CivilId
  class func isValidCivilId(civilId: String) -> Bool {
      do {
          let expression = "\\d{12}(\\.\\d?)?$"
          let regex = try NSRegularExpression(pattern: expression, options: .caseInsensitive)
          let numberOfMatches = regex.numberOfMatches(in: civilId, options: [], range: NSRange(location: 0, length: (civilId.count)))
          return numberOfMatches >= 0
      } catch let error {
          print(error)
          return false
      }
  }

  /// To check strings are empty or not
  ///
  /// - Parameter text: string
  /// - Returns: returns 'true' for string has value
  class func isStringEmpty(text: String) -> Bool {
    return text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
  }

  class func getTimestampAfter(daysInterval: Int) -> Int {
    let interval = daysInterval*60*60*24
    let date = Date(timeIntervalSinceNow: TimeInterval(interval))
    let timeStamp = Int(date.timeIntervalSince1970)
    return timeStamp
  }
}
extension Utility {
  /// Return's attributed text with abbreviation's of day's name
  ///eg: - 'S M T W T F S'
  /// - Parameter operatingDays: is operating or not
  /// - Returns:
    class func modelIdentifier() -> String {
        if let simulatorModelIdentifier = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] { return simulatorModelIdentifier }
        var sysinfo = utsname()
        uname(&sysinfo) // ignore return value
        return String(bytes: Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN)), encoding: .ascii)!.trimmingCharacters(in: .controlCharacters)
    }
    class func isIphone5() -> Bool {
//        let deviceType = Utility.modelIdentifier()
//        if deviceType.lowercased().contains("iphone5") {
//            return true
//        }
        if UIScreen.main.bounds.height <= 568 {
            return true
        }
        return false
    }



  class func appendString(data: Int) -> String {
    let value = data
    let formatter = NumberFormatter()
    formatter.minimumFractionDigits = 3 // for float
    formatter.maximumFractionDigits = 3 // for float
    formatter.minimumIntegerDigits = 1
    formatter.paddingPosition = .afterPrefix
    formatter.paddingCharacter = "0"
    return formatter.string(from: NSNumber(floatLiteral: Double(value)))!
  }

  class func appendDecimals(data: Double) -> String {
    let value = data
    let formatter = NumberFormatter()
    formatter.minimumFractionDigits = 3
    formatter.maximumFractionDigits = 3
    formatter.minimumIntegerDigits = 1
    formatter.paddingPosition = .afterPrefix
    formatter.paddingCharacter = "0"
    return formatter.string(from: NSNumber(floatLiteral: Double(value)))!
  }

  class func showAlertWith(title: String?, message: String, duration: Double, delegate: AnyObject, completion: @escaping () -> Void) {
    let alert = UIAlertController(title: title ?? "", message: message, preferredStyle: .alert)
    let viewController = delegate as? UIViewController ?? UIViewController()
    viewController.present(alert, animated: true, completion: nil)
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(duration * Double(NSEC_PER_SEC)) / Double(NSEC_PER_SEC), execute: {() -> Void in
        alert.dismiss(animated: true, completion: {
          completion()
      })
    })
  }

  class func appDelegate() -> AppDelegate {
    return (UIApplication.shared.delegate as? AppDelegate)!
  }

  class func setShadowForView(view: UIView) {
    view.layer.cornerRadius = 0
    view.clipsToBounds = false
    view.layer.shadowColor = UIColor.black.cgColor
    view.layer.shadowOffset = CGSize(width: 2, height: 2)
    view.layer.shadowRadius = 1
    view.layer.shadowOpacity = 0.2
    view.layoutIfNeeded()
  }

  class func setPadding(textField: UITextField) {
    let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: textField.frame.height))
    textField.leftView = paddingView
    textField.leftViewMode = .always

  }

  class func setShadowForCell(cell: UICollectionViewCell) {
    cell.layer.cornerRadius = 2
    cell.clipsToBounds = false
    cell.layer.shadowColor = UIColor.black.cgColor
    cell.layer.shadowOffset = CGSize(width: 1, height: 1)
    cell.layer.shadowRadius = 1
    cell.layer.shadowOpacity = 0.05
    cell.layoutIfNeeded()
  }

  class func getWidthOfLabelFromString(_ postTitle: String, font: UIFont, height: CGFloat) -> CGFloat {
    let constraintSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: height)
    let attributes = [NSAttributedString.Key.font: font]
    let labelSize = postTitle.boundingRect(with: constraintSize,
                                           options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                           attributes: attributes,
                                           context: nil)
    return labelSize.width
  }

}

extension String {
  func toBool() -> Bool? {
    switch self {
    case "True", "true", "yes", "1":
      return true
    case "False", "false", "no", "0":
      return false
    default:
      return nil
    }
  }
}
