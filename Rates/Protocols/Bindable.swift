//
//  Bindable.swift
//  Rates
//
//  Created by Michael Henry Pantaleon on 2019/08/28.
//  Copyright © 2019 Michael Henry Pantaleon. All rights reserved.
//

import Foundation

protocol Bindable {
  
  associatedtype T
  
  func bind(_ data: T)
}
