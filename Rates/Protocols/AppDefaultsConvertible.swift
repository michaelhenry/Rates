//
//  AppDefaultsConvertible.swift
//  Rates
//
//  Created by Michael Henry Pantaleon on 2019/08/30.
//  Copyright © 2019 Michael Henry Pantaleon. All rights reserved.
//

import Foundation

enum AppDefaultsKey:String {
  case lastFetchTimestamp // the last time we execute the fetch request.
  case lastQuotesTimestamp // the actual timestamp of the quotes
  case baseCurrencyCode
}

protocol AppDefaultsConvertible {
  func get<T>(for key:AppDefaultsKey) -> T?
  func set<T>(value: T?, for key:AppDefaultsKey)
}
