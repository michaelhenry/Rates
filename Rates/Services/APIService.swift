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
  
  private var apiKey:String {
    // I do recommend to set the PRODUCTION API KEY via CI ENVIRONMENT Variable
    // And on Development Environment we provide a default value so that
    // the app will continue to work without any additional configuration,
    // ONLY if this is in a PRIVATE Repo.
    guard let _apiKey = Bundle.main
      .object(forInfoDictionaryKey: "API_KEY") as? String else {
      return "0e95ff074fc3d9a7352cae4a4182224f"
    }
    return _apiKey
  }
  
  func fetchCurrencies(completion: @escaping(Result<Currencies, RequestError>) -> Void) {
    let endpoint = "api/list"
    requestCaller.call(request: request(from: endpoint), completion: completion)
  }
  
  func fetchLive(source:String = "USD", completion: @escaping(Result<Quotes, RequestError>) -> Void) {
    let endpoint = "api/live"
    requestCaller.call(request: request(from: endpoint), completion: completion)
  }
  
  private func request(from endpoint:String) -> URLRequest {
    var components = URLComponents(url: baseUrl.appendingPathComponent(endpoint), resolvingAgainstBaseURL: true)!
    components.queryItems = [URLQueryItem(name: "access_key", value: apiKey)]
    return URLRequest(url: components.url!)
  }
}
