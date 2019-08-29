//
//  ErrorInfo.swift
//  Rates
//
//  Created by Michael Henry Pantaleon on 2019/08/28.
//  Copyright © 2019 Michael Henry Pantaleon. All rights reserved.
//

struct ErrorDetail:Decodable {
  
  let code:Int
  let info:String
}

struct ErrorInfo:Error, Decodable {
  
  var error: ErrorDetail
}
