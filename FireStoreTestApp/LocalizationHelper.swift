//
//  LocalizationHelper.swift
//  vanpool-passenger-ios
//
//  Created by Akhil on 30/10/17.
//
//

import Foundation
import UIKit

extension String {
  /// Returns localized string
  var localized: String {
    return NSLocalizedString(self, comment: "")
  }

  /// Get Number corresponding to Arabic numerics
  var getNumber: Int {
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .decimal
    numberFormatter.locale = Locale(identifier: "en")
    let num = numberFormatter.number(from: self)
    return Int(truncating: num ?? 0)
  }
}

extension UIImage {
  /// To get mirrored image
  ///
  /// - Returns: Inverted image
  func getInvertedImage() -> UIImage {
    return UIImage(cgImage: self.cgImage!, scale: self.scale, orientation: UIImage.Orientation.upMirrored)
  }
}
