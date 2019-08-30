//
//  RatesViewModelTests.swift
//  RatesTests
//
//  Created by Michael Henry Pantaleon on 2019/08/30.
//  Copyright © 2019 Michael Henry Pantaleon. All rights reserved.
//

import XCTest
import CoreData
@testable import Rates

class RatesViewModelTests: XCTestCase {
  
  lazy var viewModel:RatesViewModel = {
    // For unit testing, We just need to store it in-memory
    let container = NSPersistentContainer(name: "Rates")
    let description = NSPersistentStoreDescription()
    description.type = NSInMemoryStoreType
    description.shouldAddStoreAsynchronously = false
    container.persistentStoreDescriptions = [description]
    container.loadPersistentStores { (description, error) in
      // Check if the data store is in memory
      precondition( description.type == NSInMemoryStoreType )
      if let error = error {
        fatalError("Create an in-memory coordinator failed \(error)")
      }
    }

    let context = container.viewContext
    let vm = RatesViewModel(
      api: APIService.shared,
      managedObjectContext: context, // Let's use in-memory persistent
      defaults: InMemoryAppDefaults(),
      onWillChangeContent: nil,
      onChange: nil,
      onDidChangeContent: nil,
      onReloadVisibleData: nil,
      onError:  { error in
        fatalError(error.localizedDescription)
    })
    return vm
  }()
  
  override func setUp() {
    URLProtocol.registerClass(RequestMocker.self)

    let ex = expectation(description: "wait to fetch data")
    viewModel.fetchRates() {
      ex.fulfill()
    }
    wait(for: [ex], timeout: 2.0)
  }
  
  func testBasicInfo() {
    XCTAssertEqual(viewModel.title, "Rates")
    XCTAssertEqual(viewModel.numberOfSections, 1)
    XCTAssertEqual(viewModel.numberOfItems, 0)
  }
  
  func testActivateCodeAndUpdateTheReferenceValue() {
    // Add JPY
    var ex = expectation(description: "wait to activate")
    viewModel.activate(code: "JPY") {
      ex.fulfill()
    }
    wait(for: [ex], timeout: 1.0)
    XCTAssertEqual(viewModel.numberOfItems, 1)
    
    // CHECK CONVERSION RATE OF 1.00 USD TO JPY
    var conversionRate = viewModel.item(at: indexPath(for: 0))
    XCTAssertEqual(conversionRate?.currencyCode, "JPY")
    XCTAssertEqual(conversionRate?.value, 105.760985)

    // UPDATE THE BASE CURRENCY (USD) TO 2.00
    viewModel.update(referenceValue: 2.00)
    conversionRate = viewModel.item(at: indexPath(for: 0))
    XCTAssertEqual(conversionRate?.value, 211.52197)
    
    // ADD NEW CODE ZWL
    ex = expectation(description: "wait to activate again a new code")
    viewModel.activate(code: "ZWL") {
      ex.fulfill()
    }
    wait(for: [ex], timeout: 1.0)
    XCTAssertEqual(viewModel.numberOfItems, 2)
    
    // CHANGE BACK THE BASE CURRENCY to 1.00
    viewModel.update(referenceValue: 1.00)
    conversionRate = viewModel.item(at: indexPath(for: 1))
    XCTAssertEqual(conversionRate?.currencyCode, "ZWL")
    XCTAssertEqual(conversionRate?.value, 322.000001)
    
    // DELETE RATE AT INDEX 0, WHICH IS JPY (BECAUSE CODE SORTED ALPHABETICALLY)
    ex = expectation(description: "expect to delete a code from list")
    viewModel.delete(at: indexPath(for: 0)) {
      ex.fulfill()
    }
    wait(for: [ex], timeout: 1.0)
    
    XCTAssertEqual(viewModel.numberOfItems, 1)
    
    // CHECK IF THE FIRST ITEM NOW IS ZWL
    conversionRate = viewModel.item(at: indexPath(for: 0))
    XCTAssertEqual(conversionRate?.currencyCode, "ZWL")
    XCTAssertEqual(conversionRate?.value, 322.000001)
    
    // DELETE THE LAST CODE
    ex = expectation(description: "expect to delete a code from list")
    viewModel.delete(at: indexPath(for: 0)) {
      ex.fulfill()
    }
    wait(for: [ex], timeout: 1.0)
    XCTAssertEqual(viewModel.numberOfItems, 0)
  }
  
  private func indexPath(for index:Int) -> IndexPath {
    return IndexPath(row: index, section: 0)
  }
  
  override func tearDown() {
    URLProtocol.unregisterClass(RequestMocker.self)
  }
}
