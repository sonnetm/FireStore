//
//  CCabUtilities.swift
//  gocity-cab-dev
//
//  Created by Rohit Kr on 03/10/18.
//

import Foundation
import Foundation
import GooglePlaces
import GoogleMaps
enum CCabToastDuration: Int {
  /// Have a duration of 2 sec
  case short = 2
  /// Have a duration of 5 sec
  case long = 5
}
class CCabToast {

  /// To show toast message to the user
  ///
  /// - Parameters:
  ///   - message: Message to be displayed to the user.
  ///   - controller: Viewcontroller where the toast should be presented
  ///   - duration: Time(Seconds) duration of toast.
  static func show(message: String, view: UIView, withDuration duration: Int) {
    let toastContainer = UIView(frame: CGRect())
    toastContainer.backgroundColor = UIColor.black.withAlphaComponent(0.8)
    toastContainer.alpha = 0.0
    toastContainer.layer.cornerRadius = 25
    toastContainer.clipsToBounds  =  true

    let toastLabel = UILabel(frame: CGRect())
    toastLabel.textColor = UIColor.white
    toastLabel.textAlignment = .center
    toastLabel.font.withSize(12.0)
    toastLabel.text = message
    toastLabel.clipsToBounds  =  true
    toastLabel.numberOfLines = 0

    toastContainer.addSubview(toastLabel)
    view.addSubview(toastContainer)

    toastLabel.translatesAutoresizingMaskIntoConstraints = false
    toastContainer.translatesAutoresizingMaskIntoConstraints = false

    let a1 = NSLayoutConstraint(item: toastLabel, attribute: .leading, relatedBy: .equal, toItem: toastContainer, attribute: .leading, multiplier: 1, constant: 15)
    let a2 = NSLayoutConstraint(item: toastLabel, attribute: .trailing, relatedBy: .equal, toItem: toastContainer, attribute: .trailing, multiplier: 1, constant: -15)
    let a3 = NSLayoutConstraint(item: toastLabel, attribute: .bottom, relatedBy: .equal, toItem: toastContainer, attribute: .bottom, multiplier: 1, constant: -15)
    let a4 = NSLayoutConstraint(item: toastLabel, attribute: .top, relatedBy: .equal, toItem: toastContainer, attribute: .top, multiplier: 1, constant: 15)
    toastContainer.addConstraints([a1, a2, a3, a4])

    let c1 = NSLayoutConstraint(item: toastContainer, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 20)
    let c2 = NSLayoutConstraint(item: toastContainer, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: -20)
    let c3 = NSLayoutConstraint(item: toastContainer, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: -50)
    view.addConstraints([c1, c2, c3])
    toastContainer.alpha = 1.0

    UIView.animate(withDuration: Double(duration), delay: 0.0, options: .curveEaseIn, animations: {
      toastContainer.alpha = 1.0
    }, completion: { _ in
      UIView.animate(withDuration: 0.5, delay: 1.5, options: .curveEaseOut, animations: {
        toastContainer.alpha = 0.0
      }, completion: {_ in
        toastContainer.removeFromSuperview()
      })
    })
  }

  /// To show toast message to the user with custom background opacity.
  ///
  /// - Parameters:
  ///   - message: Message to be displayed to the user.
  ///   - controller: Viewcontroller where the toast should be presented
  ///   - duration: Time(Seconds) duration of toast.
  static func show(message: String, view: UIView, withDuration duration: Int, withOpacity opacity: CGFloat) {
    let toastContainer = UIView(frame: CGRect())
    toastContainer.backgroundColor = UIColor.black.withAlphaComponent(opacity)
    toastContainer.alpha = 0.0
    toastContainer.layer.cornerRadius = 25
    toastContainer.clipsToBounds  =  true

    let toastLabel = UILabel(frame: CGRect())
    toastLabel.textColor = UIColor.white
    toastLabel.textAlignment = .center
    toastLabel.font.withSize(12.0)
    toastLabel.text = message
    toastLabel.clipsToBounds  =  true
    toastLabel.numberOfLines = 0

    toastContainer.addSubview(toastLabel)
    view.addSubview(toastContainer)

    toastLabel.translatesAutoresizingMaskIntoConstraints = false
    toastContainer.translatesAutoresizingMaskIntoConstraints = false

    let a1 = NSLayoutConstraint(item: toastLabel, attribute: .leading, relatedBy: .equal, toItem: toastContainer, attribute: .leading, multiplier: 1, constant: 15)
    let a2 = NSLayoutConstraint(item: toastLabel, attribute: .trailing, relatedBy: .equal, toItem: toastContainer, attribute: .trailing, multiplier: 1, constant: -15)
    let a3 = NSLayoutConstraint(item: toastLabel, attribute: .bottom, relatedBy: .equal, toItem: toastContainer, attribute: .bottom, multiplier: 1, constant: -15)
    let a4 = NSLayoutConstraint(item: toastLabel, attribute: .top, relatedBy: .equal, toItem: toastContainer, attribute: .top, multiplier: 1, constant: 15)
    toastContainer.addConstraints([a1, a2, a3, a4])

    let c1 = NSLayoutConstraint(item: toastContainer, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 20)
    let c2 = NSLayoutConstraint(item: toastContainer, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: -20)
    let c3 = NSLayoutConstraint(item: toastContainer, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: -50)
    view.addConstraints([c1, c2, c3])
    toastContainer.alpha = 1.0

    UIView.animate(withDuration: Double(duration), delay: 0.0, options: .curveEaseIn, animations: {
      toastContainer.alpha = 1.0
    }, completion: { _ in
      UIView.animate(withDuration: 0.5, delay: 1.5, options: .curveEaseOut, animations: {
        toastContainer.alpha = 0.0
      }, completion: {_ in
        toastContainer.removeFromSuperview()
      })
    })
  }
}
extension UIView {

  func showCCabToast(toastMessage: String, duration: CGFloat) {
    CCabToast.show(message: toastMessage, view: self, withDuration: Int(duration))
}

  @objc func handleTap(sender: UITapGestureRecognizer) {
    print("entered")
    let tag = (sender.view as? UILabel)?.tag //sender.view?.tag
    if let view = self.viewWithTag(tag ?? 0) {
      view.removeFromSuperview()
    }
  }
}
extension UIViewController {
  func toastMessage(_ message: String, isKeyboardInView: Bool) {
    guard let window = UIApplication.shared.keyWindow else {return}
    let messageLbl = UILabel()
    messageLbl.text = message
    messageLbl.textColor = UIColor.white
    messageLbl.textAlignment = .center
    messageLbl.font.withSize(12.0)
    messageLbl.text = message
    messageLbl.clipsToBounds  =  true
    messageLbl.numberOfLines = 0
    messageLbl.backgroundColor = UIColor.black.withAlphaComponent(0.8)
    let textSize: CGSize = messageLbl.intrinsicContentSize
    let labelWidth = min(textSize.width, window.frame.width - 40)

    messageLbl.frame = CGRect(x: 20, y: window.frame.height - 90, width: labelWidth + 30, height: 50)
    messageLbl.center.x = window.center.x
    messageLbl.layer.cornerRadius = messageLbl.frame.height/2
    messageLbl.layer.masksToBounds = true
    let windowCount = UIApplication.shared.windows.count
    if (isKeyboardInView) { UIApplication.shared.windows[windowCount-1].addSubview(messageLbl)
    } else {
      window.addSubview(messageLbl)
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {

      UIView.animate(withDuration: 0.5, delay: 1.5, options: .curveEaseOut, animations: {
        messageLbl.alpha = 0
      }) { (_) in
        messageLbl.removeFromSuperview()
      }
    }
  }
}
