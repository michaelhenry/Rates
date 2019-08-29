//
//  AlertShowable.swift
//  Rates
//
//  Created by Michael Henry Pantaleon on 2019/08/29.
//  Copyright © 2019 Michael Henry Pantaleon. All rights reserved.
//

import UIKit

protocol AlertShowable {
  
  func showAlert(
    title:String?,
    message:String?,
    animated:Bool,
    actions:[UIAlertAction])
}

extension AlertShowable where Self:UIViewController {
  
  func showAlert(
    title:String?,
    message:String?,
    animated:Bool = true,
    actions:[UIAlertAction]) {
    
    let alert = UIAlertController(
      title: title,
      message: message,
      preferredStyle: .alert)
    actions.forEach {
      alert.addAction($0)
    }
    present(alert, animated: animated)
  }
}
