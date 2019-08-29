//
//  CurrenciesViewController.swift
//  Rates
//
//  Created by Michael Henry Pantaleon on 2019/08/28.
//  Copyright © 2019 Michael Henry Pantaleon. All rights reserved.
//

import UIKit
import CoreData

protocol CurrenciesViewControllerDelegate:class {
  
  func currenciesVC(_ currenciesVC:CurrenciesViewController, didSelect currency:Currency)
  func currenciesVCDidCancel(_ currenciesVC:CurrenciesViewController)
}

class CurrenciesViewController:UIViewController {
  
  let searchController = UISearchController(searchResultsController: nil)
  
  weak var delegate:CurrenciesViewControllerDelegate?
  
  lazy var tableView:UITableView = {
    return UITableView(frame: .zero, style: .plain)
  }()

  lazy var viewModel:CurrenciesViewModel = {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
      fatalError("AppDelegate must not be null!")
    }
    return CurrenciesViewModel(
      api: APIService.shared,
      managedObjectContext: appDelegate.persistentContainer.viewContext,
      onWillChangeContent: { [weak self] in
        self?.tableView.beginUpdates()
      },
      onChange: { [weak self] (indexPath, type, newIndexPath) in
        guard let weakSelf = self, let _type = type else { return }
        switch (_type) {
        case .insert:
          guard let _newIndexPath = newIndexPath else { return }
          weakSelf.tableView.insertRows(at: [_newIndexPath], with: .none)
        case .update:
          guard let _indexPath = indexPath else { return }
          weakSelf.tableView.reloadRows(at: [_indexPath], with: .none)
        case .delete:
          guard let _indexPath = indexPath else { return }
          weakSelf.tableView.deleteRows(at: [_indexPath], with: .none)
        case .move:
          guard let _indexPath = indexPath, let _newIndexPath = newIndexPath else { return }
          weakSelf.tableView.moveRow(at: _indexPath, to: _newIndexPath)
        default:
          break
        }
      },
      onDidChangeContent: { [weak self] in
        self?.tableView.endUpdates()
      },
      onError:  {[weak self] error in
        guard let weakSelf = self else { return }
        weakSelf.showAlert(
          title: "Error",
          message: "\(error)",
          actions: [
            UIAlertAction(title: "Cancel", style: .cancel, handler: nil),
            UIAlertAction(
              title: "Retry",
              style: .default,
              handler: { (action) in
                weakSelf.viewModel.fetchCurrencies()
            }),
          ])
    })
  }()
  
  override func loadView() {
    super.loadView()
    view = tableView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = viewModel.title
    tableView.rowHeight = UITableView.automaticDimension
    tableView.register(CurrencyCell.self)
    tableView.dataSource = self
    tableView.delegate = self
    
    searchController.obscuresBackgroundDuringPresentation = false
    searchController.searchBar.placeholder = "Search Currencies"
    searchController.searchBar.delegate = self
    navigationItem.searchController = searchController
    definesPresentationContext = true
    
    navigationItem.rightBarButtonItem = UIBarButtonItem(
      title: "Cancel",
      style: .plain,
      target: self,
      action: #selector(CurrenciesViewController.didCancel))
    
    if viewModel.numberOfItems == 0 {
      // This must rarely update, so for now let's call this only once.
      viewModel.fetchCurrencies()
    }
  }
}

// MARK: - UITableViewDataSource
extension CurrenciesViewController:UITableViewDataSource {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return viewModel.numberOfSections
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel.numberOfItems
  }
  
  func tableView(
    _ tableView: UITableView,
    cellForRowAt indexPath: IndexPath) -> UITableViewCell {

    let cell:CurrencyCell = tableView.dequeue(CurrencyCell.self)!
    guard let currency = viewModel.currency(at: indexPath)
      else { return UITableViewCell() }
    cell.bind(currency)
    return cell
  }
}

// MARK: - UITableViewDelegate
extension CurrenciesViewController:UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    if let currency  = viewModel.currency(at: indexPath) {
      delegate?.currenciesVC(self, didSelect: currency)
    }
  }
}

// MARK: - UISearchBarDelegate
extension CurrenciesViewController:UISearchBarDelegate {
  
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    viewModel.filter(text: searchText) { [weak self] in
      self?.tableView.reloadData()
    }
  }
}

// MARK: - Extra Actions Done By User
extension CurrenciesViewController {
  
  @objc func didCancel() {
    delegate?.currenciesVCDidCancel(self)
  }
}

// MARK: - AlertShowable
extension CurrenciesViewController:AlertShowable {}
