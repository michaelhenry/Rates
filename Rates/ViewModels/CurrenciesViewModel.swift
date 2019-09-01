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
  
  var title:String
  private var isFetching:Bool = false
  
  private let api:APIService
  private var onReloadVisibleData:(() -> Void)?
  private var onError:((Error) -> Void)?

  private var fetchedResultsController: NSFetchedResultsController<Currency>
  private let managedObjectContext:NSManagedObjectContext
  private var fetchResultDelegateWrapper:NSFetchedResultsControllerDelegateWrapper
  
  init(
    action: ActionType,
    api:APIService,
    managedObjectContext:NSManagedObjectContext,
    onWillChangeContent:(() -> Void)? = nil,
    onChange:((
    _ indexPath:IndexPath?,
    _ type: NSFetchedResultsChangeType?,
    _ newIndexPath:IndexPath?) -> Void)? = nil,
    onDidChangeContent:(() -> Void)? = nil,
    onReloadVisibleData:(() -> Void)?,
    onError:((Error) -> Void)? = nil) {
    
    self.api = api
    self.managedObjectContext = managedObjectContext
    self.onReloadVisibleData = onReloadVisibleData
    self.onError = onError
    self.title = action.title
    
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
              let c = Currency(ctx: context)
              c.code = $0.key
              c.name = $0.value
            }
            try context.save()
          } catch {
            if let onError = weakSelf.onError {
              DispatchQueue.main.async {
                onError(error)
              }
            }
          }
        }
      case .failure(let error):
        if let onError = weakSelf.onError {
          DispatchQueue.main.async {
            onError(error)
          }
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
  func filter(text: String = "") {
    fetchedResultsController.fetchRequest.predicate = NSPredicate(searchText: text)
    do {
      try fetchedResultsController.performFetch()
      onReloadVisibleData?()
    } catch {
      onError?(error)
    }
  }
}

extension CurrenciesViewModel {
  
  enum ActionType {
    case changeBaseCurrency
    case addNewCurrency
    
    var title:String {
      switch self {
      case .changeBaseCurrency:
        return "Select Base Currency"
      case .addNewCurrency:
        return "Select New Currency"
      }
    }
  }
}
