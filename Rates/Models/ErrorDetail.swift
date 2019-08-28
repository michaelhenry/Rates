//
//  ErrorDetail.swift
//  Rates
//
//  Created by Michael Henry Pantaleon on 2019/08/28.
//  Copyright © 2019 Michael Henry Pantaleon. All rights reserved.
//

struct ErrorDetail:Error, Decodable {
  let code:Int
  let info:String
}
