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
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  func testFetchCurrencies() {
    let ex = expectation(description: "must have currencies")
    apiService.fetchCurrencies { result in
      switch result {
      case .success(let value):
        let currencies = value.currencies
        XCTAssert(currencies.count > 0)
        let usd = currencies["USD"]
        XCTAssertEqual(usd, "United States Dollar")
        
        let jpy = currencies["JPY"]
        XCTAssertEqual(jpy, "Japanese Yen")
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
        let currencies = value.quotes
        XCTAssert(currencies.count > 0)
   
        let usdJPY = currencies["USDJPY"]!
        XCTAssertGreaterThan(usdJPY, 0.0)
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
}
