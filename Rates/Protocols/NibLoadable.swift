//
//  NibLoadable.swift
//  Rates
//
//  Created by Michael Henry Pantaleon on 2019/08/28.
//  Copyright © 2019 Michael Henry Pantaleon. All rights reserved.
//

import UIKit
protocol NibLoadable {
  static var nib:UINib { get }
}

extension NibLoadable where Self: UIView {
  static var nib: UINib {
    let className = String(describing: self)
    return UINib(nibName: className, bundle: Bundle(for: self))
  }
}
