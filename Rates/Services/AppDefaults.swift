//
//  AppDefaults.swift
//  Rates
//
//  Created by Michael Henry Pantaleon on 2019/08/30.
//  Copyright © 2019 Michael Henry Pantaleon. All rights reserved.
//

import Foundation

class AppDefaults:AppDefaultsConvertible {
 
  static let shared = AppDefaults()
  
  private let defaults = UserDefaults.standard
  
  func get<T>(for key:AppDefaultsKey) -> T? {
    return defaults.object(forKey: key.rawValue) as? T
  }
  
  func set<T>(value: T?, for key:AppDefaultsKey) {
    defaults.set(value, forKey: key.rawValue)
  }
  
  func truncate() {
    defaults.dictionaryRepresentation()
      .keys.forEach { [weak self] in
        self?.defaults.removeObject(forKey: $0)
    }
  }
}
