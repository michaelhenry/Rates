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
  private let baseUrl:URL = URL(string: "http://apilayer.net")!
  
  private lazy var apiKey:String = {
    // I do recommend to set and override the PRODUCTION API KEY
    // via CI ENVIRONMENT Variable
    // And on Development Environment we provide a default value so that
    // the app will continue to work without any additional configuration,
    // ONLY if this is in a PRIVATE Repo.
    //
    // But for DEMO purposes, I will include this API Key
    // And there is a chance that this will revoke in the future.
    guard let _currencyLayerConfig = Bundle.main
      .object(forInfoDictionaryKey: "CurrencyLayer") as? [String: String],
      let _apiKey = _currencyLayerConfig["APIKey"] else {
      fatalError("No CurrencyLayer.APIKey found")
    }
    return _apiKey
  }()
  
  func fetchCurrencies(completion: @escaping(Result<Currencies, RequestError>) -> Void) {
    let endpoint = "api/list"
    requestCaller.call(request: request(from: endpoint), completion: completion)
  }
  
  func fetchLive(source:String, completion: @escaping(Result<Quotes, RequestError>) -> Void) {
    let endpoint = "api/live"
    requestCaller.call(
      request: request(from: endpoint,
                       queryParams: ["source": source]),
      completion: completion)
  }
  
  private func request(from endpoint:String, queryParams:[String:String] = [:]) -> URLRequest {
    var components = URLComponents(url: baseUrl.appendingPathComponent(endpoint), resolvingAgainstBaseURL: true)!
    var items = [URLQueryItem(name: "access_key", value: apiKey)]
    queryParams.forEach {
      items.append(URLQueryItem(name: $0.key, value: $0.value))
    }
    components.queryItems = items
    return URLRequest(url: components.url!)
  }
}
