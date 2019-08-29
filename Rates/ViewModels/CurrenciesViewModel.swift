//
//  CurrenciesViewModel.swift
//  Rates
//
//  Created by Michael Henry Pantaleon on 2019/08/28.
//  Copyright © 2019 Michael Henry Pantaleon. All rights reserved.
//

import Foundation
import CoreData

class CurrenciesViewModel {
  
  let title = "Select Currency"
  
  private var isFetching:Bool = false
  
  private let api:APIService
  private var onError:((Error) -> Void)?

  private var fetchedResultsController: NSFetchedResultsController<Currency>
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
    self.onError = onError
    
    fetchResultDelegateWrapper = NSFetchedResultsControllerDelegateWrapper(
      onWillChangeContent: onWillChangeContent,
      onDidChangeContent: onDidChangeContent,
      onChange: onChange)
    
    // Configure Fetch Request
    let fetchRequest: NSFetchRequest<Currency> = Currency.fetchRequest()
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
    
    if self.numberOfItems == 0 {
      // Currencies should be fetched once,
      // because it's mostly like a static information that will not change for a long time.
      self.fetchCurrencies()
    }
  }
  
  func fetchCurrencies(_ completion: (() -> Void)? = nil) {
    if isFetching { return }
    isFetching = true
    api.fetchCurrencies() {[weak self] (result) in
      guard let weakSelf = self else { return }
      
      switch result {
      case .success(let value):
        let context = weakSelf.managedObjectContext
        context.mergePolicy = NSMergePolicy.overwrite
        context.perform {
          do {
            value.currencies.forEach {
              let c = Currency(context: context)
              c.code = $0.key
              c.name = $0.value
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
  
  func currency(at indexPath:IndexPath) -> Currency? {
    let result:NSFetchRequestResult = fetchedResultsController.object(at: indexPath)
    return result as? Currency
  }
}

extension CurrenciesViewModel {

  /// Filtering the Currency list.
  ///
  /// - Parameters:
  ///   - text
  ///   - completion
  func filter(text: String = "", completion: (() -> Void)? = nil) {
    fetchedResultsController.fetchRequest.predicate = NSPredicate(searchText: text)
    do {
      try fetchedResultsController.performFetch()
      completion?()
    } catch {
      print("ERROR \(error)")
    }
  }
}
