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
  private var onWillChangeContent:(() -> Void)?
  private var onDidChangeContent:(() -> Void)?
  private var onChange:((
  _ indexPath:IndexPath?,
  _ type: NSFetchedResultsChangeType,
  _ newIndexPath:IndexPath?) -> Void)?
  
  private var fetchedResultsController: NSFetchedResultsController<Rate>
  private let managedObjectContext:NSManagedObjectContext
 
  private var fetchResultDelegateWrapper:NSFetchedResultsControllerDelegateWrapper
  
  init(
    api:APIService,
    managedObjectContext:NSManagedObjectContext,
    onWillChangeContent:(() -> Void)? = nil,
    onChange:((
    _ indexPath:IndexPath?,
    _ type: NSFetchedResultsChangeType?,
    _ newIndexPath:IndexPath?) -> Void)? = nil,
    onDidChangeContent:(() -> Void)? = nil,
    onError:((Error) -> Void)? = nil) {
    
    self.api = api
    self.managedObjectContext = managedObjectContext
    self.onWillChangeContent = onWillChangeContent
    self.onDidChangeContent = onDidChangeContent
    self.onChange = onChange
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
  }
  
  /// Activate Data Changes
  ///
  /// - Parameter completion
  func activate(completion: (() -> Void)? = nil) {
    fetchedResultsController.delegate = fetchResultDelegateWrapper
    do {
      try fetchedResultsController.performFetch()
    } catch {
      self.onError?(error)
    }
    
    if self.numberOfItems == 0 {
      self.fetchRates(completion)
    }
  }
  
  /// Deactivate Data Changes, especially on view Did disappear
  /// We don't want to listen for data changes while the viewcontroller is not showing.
  func deactivate() {
    fetchedResultsController.delegate = nil
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
}
