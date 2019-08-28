//
//  UITableView_Extensions.swift
//  Rates
//
//  Created by Michael Henry Pantaleon on 2019/08/28.
//  Copyright © 2019 Michael Henry Pantaleon. All rights reserved.
//

import UIKit
extension UITableView {
  
  func register<T: NibLoadable & Reusable >(_ c: T.Type) {
    register(T.nib, forCellReuseIdentifier: T.reuseIdentifier)
  }
  
  func dequeue<T: Reusable>(_ : T.Type) -> T? {
    return dequeueReusableCell(withIdentifier: T.reuseIdentifier) as? T
  }
  
  // For those that implemented Bindable, so no need to explicitly define the type
  func dequeue<T: Bindable & Reusable>(_ : T.Type) -> T? {
    return dequeueReusableCell(withIdentifier: T.reuseIdentifier) as? T
  }
}
