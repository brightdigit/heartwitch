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

var savedConnection : NWConnection?
let listener = try! NWListener(using: .tls)
listener.newConnectionHandler = {
  (connection) in
  if savedConnection == nil {
    savedConnection = connection
    connection.receiveMessage { (data, context, isComplete, error) in
      debugPrint(data)
    }
    let uuid = UUID()
    let data = withUnsafePointer(to: uuid) {
      Data(bytes: $0, count: MemoryLayout.size(ofValue: uuid))
    }
    
    connection.start(queue: .main)
    connection.send(content: data, completion: NWConnection.SendCompletion.contentProcessed({ (error) in
      debugPrint(error)
    }))
  } else {
    connection.cancel()
  }
 
}

listener.serviceRegistrationUpdateHandler = {
  (change) in
  print(change)
}
listener.stateUpdateHandler = {
  (state) in
  print(state)
  print(listener.port)
}
listener.start(queue: .main)

DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
  print("Dispatch works")
}

while true {
  RunLoop.current.run(mode: .default, before: Date(timeIntervalSinceNow: 0.1))
}
