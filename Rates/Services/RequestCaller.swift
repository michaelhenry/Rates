//
//  RequestCaller.swift
//  Rates
//
//  Created by Michael Henry Pantaleon on 2019/08/28.
//  Copyright © 2019 Michael Henry Pantaleon. All rights reserved.
//

import Foundation

class RequestCaller {
  
  private lazy var decoder = JSONDecoder()
  private lazy var urlSession:URLSession = URLSession(
    configuration: URLSessionConfiguration.default)
  
  /// A request call that provide Generic Decodable & HasStatus & HasErrorDetail model
  func call<Model:Decodable & HasStatus & HasErrorDetail>(
    request:URLRequest,
    completion: @escaping(Result<Model, Error>) -> Void) {
    
    let task = urlSession
      .dataTask(with: request) {[weak self] (data, response, error) in
        guard let weakSelf = self else { return }
        guard let responseData = data else {
          fatalError("""
            We're expecting a data to decode.
            Response must not be empty!
            Else it's better to use a different method that doesn't Decode the response object for better result.
          """)
        }
        do {
          let obj = try weakSelf.decoder.decode(Model.self, from: responseData)
          if obj.success {
            completion(Result.success(obj))
          } else {
            guard let err = obj.error else { fatalError("Unable to decode this error!") }
            completion(Result.failure(err))
          }
        } catch {
          completion(Result.failure(error))
        }
    }
    task.resume()
  }
}
