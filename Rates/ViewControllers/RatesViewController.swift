//
//  RatesViewController.swift
//  Rates
//
//  Created by Michael Henry Pantaleon on 2019/08/28.
//  Copyright © 2019 Michael Henry Pantaleon. All rights reserved.
//

import UIKit
import CoreData

class RatesViewController:UIViewController {
  
  @IBOutlet weak var tableView:UITableView!
  @IBOutlet weak var inputField:UITextField!
  @IBOutlet weak var currencyButton:UIButton!
  @IBOutlet weak var lastUpdatedLabel:UILabel!
  
  lazy var viewModel:RatesViewModel = {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
      fatalError("AppDelegate must not be null!")
    }
    return RatesViewModel(
      api: APIService.shared,
      managedObjectContext: appDelegate.persistentContainer.viewContext,
      defaults: AppDefaults.shared,
      onWillChangeContent: { [weak self] in
        self?.tableView.beginUpdates()
      },
      onChange: { [weak self] (indexPath, type, newIndexPath) in
        guard let weakSelf = self, let _type = type else { return }
        switch (_type) {
        case .insert:
          guard let _newIndexPath = newIndexPath else { return }
          weakSelf.tableView.insertRows(at: [_newIndexPath], with: .fade)
        case .update:
          guard let _indexPath = indexPath else { return }
          weakSelf.tableView.reloadRows(at: [_indexPath], with: .fade)
        case .delete:
          guard let _indexPath = indexPath else { return }
          weakSelf.tableView.deleteRows(at: [_indexPath], with: .fade)
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
      onReloadVisibleData: { [weak self] in
        self?.tableView.reloadData()
      },
      onError:  {[weak self] error in
        guard let weakSelf = self else { return }
        weakSelf
          .showAlert(
            title: "Error",
            message: "\(error)",
            actions: [
              UIAlertAction(title: "Cancel", style: .cancel, handler: nil),
              UIAlertAction(
                title: "Retry",
                style: .default,
                handler: { (action) in
                  weakSelf.viewModel.fetchRates()
              }),
            ])
    })
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = viewModel.title
    
    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(
      self, action: #selector(RatesViewController.refresh(_:)),
      for: .valueChanged)
    
    tableView.rowHeight = 70
    tableView.register(RateCell.self)
    tableView.dataSource = self
    tableView.delegate = self
    tableView.separatorStyle = .none
    tableView.keyboardDismissMode = .onDrag
    tableView.refreshControl = refreshControl
 
    navigationItem.rightBarButtonItem = UIBarButtonItem(
      barButtonSystemItem: .add,
      target: self, action: #selector(RatesViewController.showCurrencies))
    
    // TODO: Change the Default Currency
    
    inputField.text = "1.00"
    inputField.keyboardType = .numbersAndPunctuation
    inputField.addTarget(self, action: #selector(RatesViewController.textFieldDidChange(_:)), for: .editingChanged)
    
    // TODO: Must be better if we have custom inputView Keyboard.
    
    viewModel.fetchRates() {[weak self] in
      guard let lastQuotesTimestampText = self?.viewModel.lastQuotesTimestampText()
        else { return }
      self?.lastUpdatedLabel.text = "As of \(lastQuotesTimestampText)"
    }
  }
}

// MARK: - Actions that can be done by the User
extension RatesViewController {
  
  @objc func textFieldDidChange(_ textField:UITextField) {
    guard let text = textField.text else { return }
    viewModel.update(referenceValue: Decimal(string: text) ?? 0.0)
  }
  
  @objc func showCurrencies() {
    let currenciesVC = CurrenciesViewController()
    currenciesVC.delegate = self
    present(UINavigationController(rootViewController: currenciesVC),
            animated: true, completion: nil)
  }
  
  @objc func refresh(_ sender: UIRefreshControl) {
    viewModel.fetchRates {
      sender.endRefreshing()
    }
  }
}

// MARK: - UITableViewDataSource
extension RatesViewController:UITableViewDataSource {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return viewModel.numberOfSections
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel.numberOfItems
  }
  
  func tableView(
    _ tableView: UITableView,
    cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell:RateCell = tableView.dequeue(RateCell.self)!
    guard let rate = viewModel.item(at: indexPath)
      else { return UITableViewCell() }
    cell.bind(rate)
    return cell
  }
}

// MARK: - UITableViewDelegate
extension RatesViewController:UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    switch editingStyle {
    case .delete:
      viewModel.delete(at: indexPath)
    default:
      break
    }
  }
}

// MARK: - CurrenciesViewControllerDelegate
extension RatesViewController:CurrenciesViewControllerDelegate {
  func currenciesVCDidCancel(_ currenciesVC: CurrenciesViewController) {
    currenciesVC.dismiss(animated: true, completion: nil)
  }
  
  func currenciesVC(_ currenciesVC: CurrenciesViewController, didSelect currency: Currency) {
    guard let _code = currency.code else { return }
    currenciesVC.dismiss(animated: true) {[weak self] in
      self?.viewModel.activate(code: _code)
    }
  }
}

// MARK: - Make this ViewController AlertShowable
extension RatesViewController:AlertShowable {}
