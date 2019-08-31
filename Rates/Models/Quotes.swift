//
//  Quotes.swift
//  Rates
//
//  Created by Michael Henry Pantaleon on 2019/08/28.
//  Copyright © 2019 Michael Henry Pantaleon. All rights reserved.
//

import Foundation

struct Quotes:Decodable {
  
  typealias ConversionCode = String

  var timestamp:Date
  var source:String
  var quotes:[ConversionCode:Double]
  
  enum CodingKeys:String, CodingKey {
    case timestamp
    case source
    case quotes
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let timestampUnix = try container.decode(TimeInterval.self, forKey: .timestamp)
    quotes = try container.decode([ConversionCode:Double].self, forKey: .quotes)
    source = try container.decode(String.self, forKey: .source)
    timestamp = Date(timeIntervalSince1970: timestampUnix)
  }
}
