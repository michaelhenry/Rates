//
//  APIService.swift
//  Rates
//
//  Created by Michael Henry Pantaleon on 2019/08/28.
//  Copyright © 2019 Michael Henry Pantaleon. All rights reserved.
//

import Foundation

class APIService {
  
  static let shared = APIService()
  private lazy var requestCaller = RequestCaller()
  
  func fetchCurrencies(completion: @escaping(Result<Currencies, Error>) -> Void) {
    let request = URLRequest(
      url: URL(string: "http://apilayer.net/api/list?access_key=0e95ff074fc3d9a7352cae4a4182224f")!)
    requestCaller.call(request: request, completion: completion)
  }
  
  func fetchLive(source:String = "USD", completion: @escaping(Result<Quotes, Error>) -> Void) {
    
    let request = URLRequest(
      url: URL(string: "http://apilayer.net/api/live?access_key=0e95ff074fc3d9a7352cae4a4182224f")!)
    requestCaller.call(request: request, completion: completion)
  }
  
}
