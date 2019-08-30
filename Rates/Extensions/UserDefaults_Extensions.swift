//
//  UserDefaults_Extensions.swift
//  Rates
//
//  Created by Michael Henry Pantaleon on 2019/08/30.
//  Copyright © 2019 Michael Henry Pantaleon. All rights reserved.
//

import Foundation

extension UserDefaults {
  
  enum Key:String {
    case lastUpdateDate
    case baseCurrencyCode
  }
  
  func get<T>(for key:Key) -> T? {
    return object(forKey: key.rawValue) as? T
  }
  
  func set<T>(value: T?, for key:Key) {
    set(value, forKey: key.rawValue)
  }
}
