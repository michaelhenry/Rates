//
//  Rate+CoreDataProperties.swift
//  Rates
//
//  Created by Michael Henry Pantaleon on 2019/08/29.
//  Copyright © 2019 Michael Henry Pantaleon. All rights reserved.
//
//

import Foundation
import CoreData

extension Rate {
  
  @nonobjc public class func fetchRequest() -> NSFetchRequest<Rate> {
    let request = NSFetchRequest<Rate>(entityName: "Rate")
    request.fetchBatchSize = 30
    let nameSort = NSSortDescriptor(keyPath: \Rate.currencyCode, ascending: true)
    request.sortDescriptors = [nameSort]
    return request
  }
  
  @NSManaged public var value: NSDecimalNumber?
  @NSManaged public var currencyCode: String?
  
}


