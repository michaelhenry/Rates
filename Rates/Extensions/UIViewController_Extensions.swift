//
//  UIViewController_Extensions.swift
//  Rates
//
//  Created by Michael Henry Pantaleon on 2019/08/28.
//  Copyright © 2019 Michael Henry Pantaleon. All rights reserved.
//

import UIKit

extension UIViewController {
  
  func showAlert(
    title:String?,
    message:String?,
    animated:Bool = true,
    actions:[UIAlertAction]) {
    
    let alert = UIAlertController(
      title: title,
      message: message,
      preferredStyle: .alert)
    present(alert, animated: animated)
  }
}
