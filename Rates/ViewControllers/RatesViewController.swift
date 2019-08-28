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
  
  lazy var apiService = APIService()
  
  lazy var viewModel:RatesViewModel = {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
      fatalError("AppDelegate must not be null!")
    }
    return RatesViewModel(
      api: APIService.shared,
      managedObjectContext: appDelegate.persistentContainer.viewContext,
      onWillChangeContent: { [weak self] in
        guard let weakSelf = self else { return }
        weakSelf.tableView.beginUpdates()
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
        guard let weakSelf = self else { return }
        weakSelf.tableView.endUpdates()
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
                weakSelf.viewModel.fetchRates()
            }),
          ])
    })
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = viewModel.title
    tableView.rowHeight = UITableView.automaticDimension
    tableView.register(RateCell.self)
    tableView.dataSource = self
    tableView.delegate = self
    
    currencyButton.addTarget(
      self,
      action: #selector(RatesViewController.showCurrencies),
      for: .touchUpInside)
    
    navigationItem.rightBarButtonItem = UIBarButtonItem(
      barButtonSystemItem: .add,
      target: self, action: #selector(RatesViewController.showCurrencies))
    
    inputField.text = "1"
    inputField.keyboardType = .numberPad
  }
  
  @objc func showCurrencies() {
    let currenciesVC = CurrenciesViewController()
    currenciesVC.delegate = self
    present(UINavigationController(rootViewController: currenciesVC),
            animated: true, completion: nil)
  }
  
}

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
    guard let rate = viewModel.rate(at: indexPath)
      else { return UITableViewCell() }
    cell.bind(rate)
    return cell
  }
}

extension RatesViewController:UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    if let rate  = viewModel.rate(at: indexPath) {
      print("rate \(rate)")
    }
  }
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    switch editingStyle {
    case .delete:
      viewModel.delete(at: indexPath)
    default:
      break
    }
  }
}

extension RatesViewController:CurrenciesViewControllerDelegate {
  func currenciesVCDidCancel(_ currenciesVC: CurrenciesViewController) {
    currenciesVC.dismiss(animated: true, completion: nil)
  }
  
  func currenciesVC(_ currenciesVC: CurrenciesViewController, didSelect currency: Currency) {
    print(currency)
    guard let _code = currency.code else { return }
    viewModel.activate(code: _code)
    currenciesVC.dismiss(animated: true, completion: nil)
  }
}
