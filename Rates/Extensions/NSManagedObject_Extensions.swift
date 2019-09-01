//
//  NSManagedObject_Extensions.swift
//  Rates
//
//  Created by Michael Henry Pantaleon on 2019/09/01.
//  Copyright © 2019 Michael Henry Pantaleon. All rights reserved.
//

import CoreData

public extension NSManagedObject {
  
  convenience init(ctx: NSManagedObjectContext) {
    let name = String(describing: type(of: self))
    let entity = NSEntityDescription.entity(forEntityName: name, in: ctx)!
    self.init(entity: entity, insertInto: ctx)
  }
}
