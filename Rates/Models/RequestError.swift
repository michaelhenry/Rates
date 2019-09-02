//
//  RequestError.swift
//  Rates
//
//  Created by Michael Henry Pantaleon on 2019/08/29.
//  Copyright © 2019 Michael Henry Pantaleon. All rights reserved.
//

import Foundation

enum RequestError:Error, CustomStringConvertible {
  case responseError(ErrorDetail)
  case unknownError(String)
  case unreachable
  
  var description: String {
    switch self {
    case .responseError(let detail):
      return detail.info
    case .unknownError(let msg):
      return msg
    case .unreachable:
      return "Please check your internet connection."
    }
  }
}
