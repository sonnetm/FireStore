//
//  CCabRetryRequestViewController.swift
//  MapKitReuse
//
//  Created by Aravind on 29/09/18.
//  Copyright © 2018 Aravind. All rights reserved.
//

import UIKit

class CCabRetryRequestViewController: CCabBaseViewController {
  @IBOutlet weak var newCabsAvailableLabel: UILabel!
  @IBOutlet weak var tryAgainButton: UIButton!
  @IBOutlet weak var pleaseTryAgainLabel: UILabel!
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    self.setupData()
    // Do any additional setup after loading the view.
    self.setFontSizeAndColor()
  }
  // MARK: - Initialise data
  func setFontSizeAndColor() {
    self.newCabsAvailableLabel.font = UIFont.systemFont(ofSize: 17.0)
    self.pleaseTryAgainLabel.font = UIFont.systemFont(ofSize: 15.0)
    self.tryAgainButton.layer.cornerRadius = 6
    self.tryAgainButton.clipsToBounds = true
    self.tryAgainButton.titleLabel?.font = UIFont.systemFont(ofSize: 17.0)
    self.tryAgainButton.titleLabel?.textColor = UIColor.white
  }
  func setupData() {
    self.newCabsAvailableLabel.text = "No cabs available"
    self.pleaseTryAgainLabel.text = "Please Try Again"
    self.tryAgainButton.setTitle("Try Again", for: .normal)
  }
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  @IBAction func tryAgainButtonAction(_ sender: Any) {
    
  }
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destinationViewController.
   // Pass the selected object to the new view controller.
   }
   */

}
