//
//  main.swift
//  heartwitch-server
//
//  Created by Leo Dion on 6/30/19.
//  Copyright © 2019 BrightDigit. All rights reserved.
//
import Foundation
import Dispatch
import Network

var webConnection : NWConnection?
var heartRateConnection : NWConnection?
let heartRateListener = try! NWListener(using: .tcp)
heartRateListener.newConnectionHandler = {
  (connection) in
  if heartRateConnection == nil {
    heartRateConnection = connection
    connection.receiveMessage { (data, context, isComplete, error) in
      debugPrint(data)
      webConnection?.send(content: data, completion: NWConnection.SendCompletion.contentProcessed({ (error) in
        debugPrint(error)
      }))
    }
    let uuid = UUID()
    let data = withUnsafePointer(to: uuid) {
      Data(bytes: $0, count: MemoryLayout.size(ofValue: uuid))
    }
    
    connection.start(queue: .main)
    
  } else {
    connection.cancel()
  }
  
}

heartRateListener.serviceRegistrationUpdateHandler = {
  (change) in
  print(change)
}
heartRateListener.stateUpdateHandler = {
  (state) in
  print(state)
  print("Heart", heartRateListener.port)
}
heartRateListener.start(queue: .main)

let webListener = try! NWListener(using: .tcp)
webListener.newConnectionHandler = {
  (connection) in
  if let webConnection = webConnection {
    webConnection.cancel()
  }
  
  webConnection = connection
  
  connection.start(queue: .main)
  let data = withUnsafePointer(to: heartRateListener.port) {
    Data(bytes: $0, count: MemoryLayout.size(ofValue: heartRateListener.port))
  }
  
  connection.send(content: data, completion: NWConnection.SendCompletion.contentProcessed({ (error) in
    debugPrint(error)
  }))
  
}

webListener.serviceRegistrationUpdateHandler = {
  (change) in
  print(change)
}
webListener.stateUpdateHandler = {
  (state) in
  print(state)
  print("Web", webListener.port)
}
webListener.start(queue: .main)
DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
  print("Dispatch works")
}

while true {
  RunLoop.current.run(mode: .default, before: Date(timeIntervalSinceNow: 0.1))
}
