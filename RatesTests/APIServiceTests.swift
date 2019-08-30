//
//  APIServiceTests.swift
//  RatesTests
//
//  Created by Michael Henry Pantaleon on 2019/08/28.
//  Copyright © 2019 Michael Henry Pantaleon. All rights reserved.
//

import XCTest
@testable import Rates

class APIServiceTests: XCTestCase {
  
  let apiService = APIService()
  
  override func setUp() {
    URLProtocol.registerClass(RequestMocker.self)
  }
  
  func testFetchCurrencies() {
    let ex = expectation(description: "must have currencies")
    apiService.fetchCurrencies { result in
      switch result {
      case .success(let value):
        let currencies = value.currencies
        XCTAssertEqual(currencies.count, 4)
        XCTAssertEqual(currencies["USD"], "United States Dollar")
        XCTAssertEqual(currencies["JPY"], "Japanese Yen")
        XCTAssertEqual(currencies["AED"], "United Arab Emirates Dirham")
        XCTAssertEqual(currencies["ZWL"], "Zimbabwean Dollar")
      case .failure(let error):
        switch error {
        case .responseError(let detail):
           XCTFail(detail.info)
        default:
          XCTFail(error.localizedDescription)
        }
      }
      ex.fulfill()
    }
    wait(for: [ex], timeout: 2.0)
  }
  
  func testFetchQuotes() {
    let ex = expectation(description: "must have quotes")
    apiService.fetchLive { result in
      switch result {
      case .success(let value):
        XCTAssertEqual(value.timestamp, Date(timeIntervalSince1970: 1566922086))
        let quotes = value.quotes
        XCTAssertEqual(quotes.count, 4)
        XCTAssertEqual(quotes["USDAED"], 3.673007)
        XCTAssertEqual(quotes["USDJPY"], 105.760985)
        XCTAssertEqual(quotes["USDUSD"], 1)
        XCTAssertEqual(quotes["USDZWL"], 322.000001)
      case .failure(let error):
        switch error {
        case .responseError(let detail):
          XCTFail(detail.info)
        default:
          XCTFail(error.localizedDescription)
        }
      }
      ex.fulfill()
    }
    wait(for: [ex], timeout: 2.0)
  }
  
  override func tearDown() {
    URLProtocol.unregisterClass(RequestMocker.self)
  }
  
}
