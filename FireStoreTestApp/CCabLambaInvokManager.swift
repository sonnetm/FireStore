//
//  CCabLambaInvokManager.swift
//  vanpool-passenger-ios
//
//  Created by Aravind on 13/10/18.
//

import Foundation
import AWSAppSync
import AWSLambda
//FareEstimation
enum LambdaRoute {
	case completeRide
	var path: String {
		switch self {
		case .completeRide:
			return "FirestoreCompleteRide"
 
		}
	}
}

class LambdaInvokeManger {

	class func invokeLambdaForRoute(lambdaRoute: LambdaRoute, withParam dict: [String: Any], completionHandler: @escaping (AnyObject?, _ error: String?) -> Void) {
//		let appDelegate = UIApplication.shared.delegate as? AppDelegate
//		appSyncClient = appDelegate?.appSyncClient!
		print("lambda name for target -\(lambdaRoute.path)")
   let lambdaInvoker = AWSLambdaInvoker.default()
	 lambdaInvoker.invokeFunction(lambdaRoute.path, jsonObject: dict)
	.continueWith(block: {(task: AWSTask<AnyObject>) -> Any? in
		if (task.error != nil) {
		print("Error: \(task.error!)")
		completionHandler(nil, task.error?.localizedDescription ?? "")
		} else {
	   let dataValue = task.result as? String
			completionHandler(task.result, nil)
			}
		return nil
		})
  }
}
struct LambdaInvokeData {
	public var appSyncLocalDbName: String {return "citycab-app-db"}
	public var appSyncPoolId: String {
		return "ap-south-1:769ee023-c15e-47a3-8812-8e6cd53b7347"//"ap-south-1:769ee023-c15e-47a3-8812-8e6cd53b7347"
	}
}

