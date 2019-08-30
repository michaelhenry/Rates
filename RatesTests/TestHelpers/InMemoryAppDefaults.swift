//
//  InMemoryAppDefaults.swift
//  RatesTests
//
//  Created by Michael Henry Pantaleon on 2019/08/30.
//  Copyright © 2019 Michael Henry Pantaleon. All rights reserved.
//

@testable import Rates

class InMemoryAppDefaults:AppDefaultsConvertible {
  
  var defaults:[AppDefaultsKey: Any] = [:]
  
  func get<T>(for key:AppDefaultsKey) -> T? {
    return defaults[key] as? T
  }
  
  func set<T>(value: T?, for key:AppDefaultsKey) {
    defaults[key] = value
  }
}
