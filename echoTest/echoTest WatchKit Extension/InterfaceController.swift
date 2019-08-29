//
//  InterfaceController.swift
//  echoTest WatchKit Extension
//
//  Created by Leo Dion on 8/28/19.
//  Copyright © 2019 BrightDigit. All rights reserved.
//

import WatchKit
import Foundation

struct Post : Codable {
  let id : Int?
  let title: String
  let body : String
  let userId : Int
}

class InterfaceController: WKInterfaceController {
  let jsonEncoder = JSONEncoder()
  let jsonDecoder = JSONDecoder()
  
  override func awake(withContext context: Any?) {
    super.awake(withContext: context)
    
    // Configure interface objects here.
    let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer) in
      var urlRequest = URLRequest(url: URL(string: "https://jsonplaceholder.typicode.com/posts")!)
      urlRequest.httpBody = try! self.jsonEncoder.encode(Post(id: nil, title: "test", body: "test", userId: Int.random(in: 1...300)))
      urlRequest.httpMethod = "POST"
      urlRequest.addValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-type")
      let task = URLSession.shared.dataTask(with: urlRequest, completionHandler: self.onResponse)
      task.resume()
    }
  }
  
  func onResponse(data: Data?, response: URLResponse?, error: Error?) {
    if let error = error {
      print(error)
      return
    }
    guard let data = data else {
      return
    }
    let post = try! jsonDecoder.decode(Post.self, from: data)
    print(post.id)
  }
  
  override func willActivate() {
    // This method is called when watch view controller is about to be visible to user
    super.willActivate()
  }
  
  override func didDeactivate() {
    // This method is called when watch view controller is no longer visible
    super.didDeactivate()
  }
  
}
