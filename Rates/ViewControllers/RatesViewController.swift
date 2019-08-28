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
  
  lazy var tableView:UITableView = {
    return UITableView(frame: .zero, style: .plain)
  }()
  
  lazy var apiService = APIService()
  
  override func loadView() {
    super.loadView()
    view = tableView
  }
  
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
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    viewModel.activate()
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    viewModel.deactivate()
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
}
