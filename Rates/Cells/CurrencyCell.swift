//
//  CurrencyCell.swift
//  Rates
//
//  Created by Michael Henry Pantaleon on 2019/08/28.
//  Copyright © 2019 Michael Henry Pantaleon. All rights reserved.
//

import UIKit

class CurrencyCell: UITableViewCell, Bindable{
  
  typealias T = Currency
  
  @IBOutlet weak var codeLabel:UILabel!
  @IBOutlet weak var nameLabel:UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  func bind(_ data:T) {
    codeLabel.text = data.code
    nameLabel.text = data.name
  }
}

