//
//  shimmer.swift
//  MapKitReuse
//
//  Created by Aravind on 27/09/18.
//  Copyright © 2018 Aravind. All rights reserved.
//

import UIKit

var cutoutHandle: UInt8         = 0
var gradientHandle: UInt8       = 0
var loaderDuration              = 0.85
var gradientWidth               = 0.17
var gradientFirstStop           = 0.1
extension CGFloat {
	func doubleValue() -> Double {
		return Double(self)
	}
}

@objc extension UIColor {
	static func backgroundFadedGrey() -> UIColor {
		//return UIColor(red: (246.0/255.0), green: (247.0/255.0), blue: (248.0/255.0), alpha: 1)
	    return  UIColor(red: 0.88, green: 0.91, blue: 0.98, alpha: 1)
	}

	static func gradientFirstStop() -> UIColor {
		//return  UIColor(red: (238.0/255.0), green: (238.0/255.0), blue: (238.0/255.0), alpha: 1.0)
		return UIColor(red: 1.00, green: 1.00, blue: 1.00, alpha: 1)
	}

	static func gradientSecondStop() -> UIColor {
		//return UIColor(red: (221.0/255.0), green: (221.0/255.0), blue:(221.0/255.0) , alpha: 1.0);
		 return  UIColor(red: 0.88, green: 0.91, blue: 0.98, alpha: 1)
	}
}
class GradientAnimator: NSObject {

	static func addLoaderToViews(_ views: [UIView]) {
		CATransaction.begin()
		views.forEach { $0.ld_addLoader() }
		CATransaction.commit()
	}

}

extension UIView {

	public func showGradientAnimation() {
		self.isUserInteractionEnabled = false
			GradientAnimator.addLoaderToViews(self.subviews)
		}

	fileprivate func ld_getCutoutView() -> UIView? {
    return (objc_getAssociatedObject(self, &cutoutHandle) as? UIView?)!
	}

	fileprivate func ld_setCutoutView(_ aView: UIView) {
		return objc_setAssociatedObject(self, &cutoutHandle, aView, .OBJC_ASSOCIATION_RETAIN)
	}

	fileprivate func ld_getGradient() -> CAGradientLayer? {
    return (objc_getAssociatedObject(self, &gradientHandle) as? CAGradientLayer?)!
	}

	fileprivate func ld_setGradient(_ aLayer: CAGradientLayer) {
		return objc_setAssociatedObject(self, &gradientHandle, aLayer, .OBJC_ASSOCIATION_RETAIN)
	}
	func showShimmer() {
		self.ld_addLoader()
	}

	fileprivate func ld_addLoader() {
		let gradient: CAGradientLayer = CAGradientLayer()
		gradient.frame = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height)
		if self.layer.cornerRadius > 0 {
			gradient.cornerRadius = self.layer.cornerRadius
		}
		self.layer.insertSublayer(gradient, at: 0)

		self.configureAndAddAnimationToGradient(gradient)
		//self.addCutoutView()
	}
	func configureAndAddAnimationToGradient(_ gradient: CAGradientLayer) {
		gradient.startPoint = CGPoint(x: -1.0 + CGFloat(gradientWidth), y: 0)
		gradient.endPoint = CGPoint(x: 1.0 + CGFloat(gradientWidth), y: 0)

		gradient.colors = [
			UIColor.backgroundFadedGrey().cgColor,
			UIColor.gradientFirstStop().cgColor,
			UIColor.gradientSecondStop().cgColor,
			UIColor.gradientFirstStop().cgColor,
			UIColor.backgroundFadedGrey().cgColor
		]
    var startLocationsArabic = [NSNumber(value: 1 + gradientWidth as Double), NSNumber(value: 1 + gradientWidth as Double), NSNumber(value: 0 as Double), NSNumber(value: gradient.startPoint.x.doubleValue() as Double), NSNumber(value: gradient.startPoint.x.doubleValue() as Double)]

    var startLocationsEnglish = [NSNumber(value: gradient.startPoint.x.doubleValue() as Double), NSNumber(value: gradient.startPoint.x.doubleValue() as Double), NSNumber(value: 0 as Double), NSNumber(value: gradientWidth as Double), NSNumber(value: 1 + gradientWidth as Double)]

    var animationToValueEnglish = [NSNumber(value: 0 as Double), NSNumber(value: 1 as Double), NSNumber(value: 1 as Double), NSNumber(value: 1 + (gradientWidth - gradientFirstStop) as Double), NSNumber(value: 1 + gradientWidth as Double)]

    var startLocations = [NSNumber]()
    let gradientAnimation = CABasicAnimation(keyPath: "locations")
      startLocations = startLocationsEnglish
      gradient.locations = startLocations
      gradientAnimation.fromValue = startLocations
      gradientAnimation.toValue = animationToValueEnglish

		gradientAnimation.repeatCount = Float.infinity
		gradientAnimation.fillMode = CAMediaTimingFillMode.both
		gradientAnimation.isRemovedOnCompletion = false
		gradientAnimation.duration = loaderDuration
		gradient.add(gradientAnimation, forKey: "locations")

		self.ld_setGradient(gradient)

	}
	func removeLoader() {
		ld_removeLoader()
	}
	fileprivate func ld_removeLoader() {
		self.ld_getCutoutView()?.removeFromSuperview()
		self.ld_getGradient()?.removeAllAnimations()
		self.ld_getGradient()?.removeFromSuperlayer()

		for view in self.subviews {
			view.alpha = 1
		}
	}

	/*
	// Only override draw() if you perform custom drawing.
	// An empty implementation adversely affects performance during animation.
	override func draw(_ rect: CGRect) {
	// Drawing code
	}
	*/

}
