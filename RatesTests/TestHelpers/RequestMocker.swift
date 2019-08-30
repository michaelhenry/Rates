//
//  RequestMocker.swift
//  Rates
//
//  Created by Michael Henry Pantaleon on 2019/08/29.
//  Copyright © 2019 Michael Henry Pantaleon. All rights reserved.
//

import Foundation

class RequestMocker:URLProtocol {
  override class func canInit(with request: URLRequest) -> Bool {
    return true
  }
  
  override class func canonicalRequest(for request: URLRequest) -> URLRequest {
    return request
  }
  
  override func startLoading() {
    guard let path = request.url?.path,
      let mockUrl = urlOfFile(endpoint: path),
      let mockData = try? Data(contentsOf: mockUrl) else { return }
    
    let urlResponse = URLResponse(
      url: request.url!,
      mimeType: "application/json",
      expectedContentLength: mockData.count,
      textEncodingName: "utf-8")
    
    client?.urlProtocol(self, didReceive: urlResponse, cacheStoragePolicy: .notAllowed)
    client?.urlProtocol(self, didLoad: mockData)
    client?.urlProtocolDidFinishLoading(self)
  }
  
  override func stopLoading() {
    
  }
  
  private func urlOfFile(endpoint:String) -> URL? {
    
    guard let mockResourcesFolderUrl = Bundle(
      for: type(of: self))
      .resourceURL?.appendingPathComponent("mock-resources")
      else {
        fatalError("Cannot find the mock-resources folder")
    }
    return mockResourcesFolderUrl.appendingPathComponent("\(endpoint).json")
  }
  
}
