//
//  ViewController.swift
//  Rates
//
//  Created by Michael Henry Pantaleon on 2019/08/27.
//  Copyright © 2019 Michael Henry Pantaleon. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationItem.leftBarButtonItem = UIBarButtonItem(
      title: "Currencies",
      style: .plain,
      target: self,
      action: #selector(ViewController.showCurrencies))
    
    navigationItem.rightBarButtonItem = UIBarButtonItem(
      title: "Rates",
      style: .plain,
      target: self,
      action: #selector(ViewController.showRates))
  }
  
  @objc func showCurrencies() {
    let currenciesVC = CurrenciesViewController()
    navigationController?.pushViewController(currenciesVC, animated: true)
  }
  
  @objc func showRates() {
    let ratesVC = RatesViewController()
    navigationController?.pushViewController(ratesVC, animated: true)
  }
  
}


