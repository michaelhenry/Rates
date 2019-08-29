//
//  Quotes.swift
//  Rates
//
//  Created by Michael Henry Pantaleon on 2019/08/28.
//  Copyright © 2019 Michael Henry Pantaleon. All rights reserved.
//

import Foundation

struct Quotes:Decodable {
  
  var timestamp:Int
  var quotes:[String:Double]
}
