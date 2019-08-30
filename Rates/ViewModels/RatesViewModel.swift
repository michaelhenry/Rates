//
//  RatesViewModel.swift
//  Rates
//
//  Created by Michael Henry Pantaleon on 2019/08/28.
//  Copyright © 2019 Michael Henry Pantaleon. All rights reserved.
//

import Foundation
import CoreData

class RatesViewModel {
  
  let title = "Rates"
  
  private var isFetching:Bool = false
  
  private let api:APIService
  private var onError:((Error) -> Void)?
  private var onReloadVisibleData:(() -> Void)?
  
  private var fetchedResultsController: NSFetchedResultsController<Rate>
  private let managedObjectContext:NSManagedObjectContext
 
  private var fetchResultDelegateWrapper:NSFetchedResultsControllerDelegateWrapper
  
  private var referenceValue:Decimal = 1.0
  
  init(
    api:APIService,
    managedObjectContext:NSManagedObjectContext,
    onWillChangeContent:(() -> Void)? = nil,
    onChange:((
    _ indexPath:IndexPath?,
    _ type: NSFetchedResultsChangeType?,
    _ newIndexPath:IndexPath?) -> Void)? = nil,
    onDidChangeContent:(() -> Void)? = nil,
    onReloadVisibleData:(() -> Void)? = nil,
    onError:((Error) -> Void)? = nil) {
    
    self.api = api
    self.managedObjectContext = managedObjectContext
    self.onReloadVisibleData = onReloadVisibleData
    self.onError = onError
    
    fetchResultDelegateWrapper = NSFetchedResultsControllerDelegateWrapper(
      onWillChangeContent: onWillChangeContent,
      onDidChangeContent: onDidChangeContent,
      onChange: onChange)
    
    // Configure Fetch Request
    let fetchRequest: NSFetchRequest<Rate> = Rate.fetchRequest()
    
    fetchedResultsController = NSFetchedResultsController(
      fetchRequest: fetchRequest,
      managedObjectContext: managedObjectContext,
      sectionNameKeyPath: nil,
      cacheName: nil)
    
    fetchedResultsController.delegate = fetchResultDelegateWrapper
    do {
      try fetchedResultsController.performFetch()
    } catch {
      self.onError?(error)
    }
  }
  
  func fetchRates(_ completion: (() -> Void)? = nil) {
    if isFetching { return }
    isFetching = true
    api.fetchLive() {[weak self] (result) in
      guard let weakSelf = self else { return }
      
      switch result {
      case .success(let value):
        let context = weakSelf.managedObjectContext
        context.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        context.perform {
          do {
            value.quotes.forEach {
              let r = Rate(context: context)
              // code will be like Source-Target like `USDGBP`
              // so let's clean the data before saving to our database since we only support 1 conversion at a time
              r.currencyCode = String($0.key.suffix(3))
              r.value = NSDecimalNumber(floatLiteral: $0.value) 
            }
            try context.save()
          } catch {
            DispatchQueue.main.async {
              weakSelf.onError?(error)
            }
          }
        }
      case .failure(let error):
        DispatchQueue.main.async {
          weakSelf.onError?(error)
        }
      }
      weakSelf.isFetching = false
      completion?()
    }
  }
  
  var numberOfItems:Int {
    return fetchedResultsController.fetchedObjects?.count ?? 0
  }
  
  var numberOfSections:Int {
    return 1
  }
  
  func rate(at indexPath:IndexPath) -> Rate? {
    let result:NSFetchRequestResult = fetchedResultsController.object(at: indexPath)
    return result as? Rate
  }
  
  func delete(at indexPath:IndexPath) {
    let result:NSFetchRequestResult = fetchedResultsController.object(at: indexPath)
    managedObjectContext.perform { [weak self] in
      do {
        (result as! Rate).active = false
        try self?.managedObjectContext.save()
      } catch {
        print(error)
      }
    }
  }
  
  func activate(code:String, completion: (() -> Void)? = nil) {
    managedObjectContext.perform { [weak self] in
      do {
        let fetchRequest:NSFetchRequest<Rate> = Rate.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "currencyCode = %@", code)
        fetchRequest.fetchLimit = 1
        let result = try self?.managedObjectContext.fetch(fetchRequest)
        result?.first?.active = true
        try self?.managedObjectContext.save()
        completion?()
      } catch {
        print(error)
      }
    }
  }
  
  func item(at indexPath:IndexPath) -> EquivalentRate? {
    guard let obj = rate(at: indexPath) else { return nil }
    return obj.equivalentRate(at: NSDecimalNumber(decimal: referenceValue))
  }
}

extension RatesViewModel {
  
  func update(referenceValue: Decimal) {
    self.referenceValue = referenceValue
    onReloadVisibleData?()
  }
}
