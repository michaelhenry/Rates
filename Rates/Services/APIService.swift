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
  
  private var apiKey:String {
    // I do recommend to set the PRODUCTION API KEY via CI ENVIRONMENT Variable and
    // on Development Environment we provide a default so that
    // the app will continue to work without any additional configuration,
    // only if this is a private repository.
    guard let _apiKey = Bundle.main
      .object(forInfoDictionaryKey: "API_KEY") as? String else {
      return "0e95ff074fc3d9a7352cae4a4182224f"
    }
    return _apiKey
  }
  
  func fetchCurrencies(completion: @escaping(Result<Currencies, RequestError>) -> Void) {
    let request = URLRequest(
      url: URL(string: "http://apilayer.net/api/list?access_key=\(apiKey)")!)
    requestCaller.call(request: request, completion: completion)
  }
  
  func fetchLive(source:String = "USD", completion: @escaping(Result<Quotes, RequestError>) -> Void) {
    
    let request = URLRequest(
      url: URL(string: "http://apilayer.net/api/live?access_key=\(apiKey)")!)
    requestCaller.call(request: request, completion: completion)
  }
}
