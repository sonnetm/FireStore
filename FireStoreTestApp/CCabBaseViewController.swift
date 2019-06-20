//
//  CCabBaseViewController.swift
//  FireStoreTestApp
//
//  Created by Rohit Kr on 29/04/19.
//  Copyright © 2019 Rohit Kr. All rights reserved.
//

import UIKit

class CCabBaseViewController: UIViewController {
  var popAnimated = true
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
  
  func setBackButtonNavigationBar(title: String, isBackButtonRequired: Bool, controller: UIViewController) {
    self.customNavigationBarWithBackBtnBlue(title: title, isBackRequired: isBackButtonRequired, controller: controller)
  }
  
  @objc func popBack() {
    _ = navigationController?.popViewController(animated: popAnimated)
  }
  
  func customNavigationBarWithBackBtnBlue(title: String, isBackRequired: Bool, controller: UIViewController) {
    self.navigationController?.navigationBar.tintColor = UIColor(red: 0.00, green: 0.27, blue: 0.88, alpha: 1)
    self.navigationController?.navigationBar.isTranslucent = false
    self.navigationController?.view.backgroundColor = .clear
    self.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedString.Key.font: UIFont.systemFont(ofSize: 19.0, weight: .medium), NSAttributedString.Key.foregroundColor: UIColor(red: 0.00, green: 0.27, blue: 0.88, alpha: 1)]
    self.navigationItem.title = title
    if isBackRequired {
      let backArrowImage = UIImage(named: "backBlue")
      let itemView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
      var itemImageView = UIImageView(frame: CGRect(x: 0, y: 10, width: 24, height: 24))
      itemImageView.backgroundColor = UIColor.clear
      itemView.backgroundColor = UIColor.clear
      itemImageView.contentMode = .scaleAspectFit
      itemImageView.clipsToBounds = true
      let button: UIButton = UIButton(type: UIButton.ButtonType.custom)
      button.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
      button.clipsToBounds = true
      itemImageView.image = backArrowImage
      button.addTarget(self, action: #selector(popBack), for: UIControl.Event.touchUpInside)
      itemView.addSubview(button)
      itemView.insertSubview(itemImageView, belowSubview: button)
      navigationItem.leftBarButtonItem =  UIBarButtonItem(customView: itemView)
      self.navigationItem.hidesBackButton = false
    } else {
      self.navigationItem.hidesBackButton = true
    }
    navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    navigationController?.navigationBar.shadowImage = UIImage()
  }

  func addShadow() {
    navigationController?.navigationBar.layer.masksToBounds = false
    navigationController?.navigationBar.layer.shadowColor = UIColor(red: 0.40, green: 0.40, blue: 0.40, alpha: 1).cgColor
    navigationController?.navigationBar.layer.shadowOpacity = 0.18
    navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0, height: 10)
    navigationController?.navigationBar.layer.shadowRadius = 6
    navigationController?.navigationBar.layer.borderColor = UIColor.white.cgColor
    navigationController?.navigationBar.backgroundColor = .white
    navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    navigationController?.navigationBar.shadowImage = UIImage()
  }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
