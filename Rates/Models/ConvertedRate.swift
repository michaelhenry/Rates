//
//  EquivalentRate.swift
//  Rates
//
//  Created by Michael Henry Pantaleon on 2019/08/29.
//  Copyright © 2019 Michael Henry Pantaleon. All rights reserved.
//

import Foundation

struct EquivalentRate {
  var currencyCode:String?
  var value:NSDecimalNumber?
}

extension Rate {
  func equivalentRate(at rate: NSDecimalNumber) -> EquivalentRate {
    return EquivalentRate(currencyCode: currencyCode, value: value?.multiplying(by: rate))
  }
}
