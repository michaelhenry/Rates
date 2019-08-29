//
//  RateCell.swift
//  Rates
//
//  Created by Michael Henry Pantaleon on 2019/08/28.
//  Copyright © 2019 Michael Henry Pantaleon. All rights reserved.
//

import UIKit

class RateCell: UITableViewCell, Bindable {
  
  typealias T = EquivalentRate
  
  @IBOutlet weak var codeLabel:UILabel!
  @IBOutlet weak var valueLabel:UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    selectionStyle = .none
  }
  
  func bind(_ data: T) {
    codeLabel.text = data.currencyCode
    valueLabel.text = data.value?.stringValue
  }
}

