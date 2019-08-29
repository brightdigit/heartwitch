//
//  InterfaceController.swift
//  echoTest WatchKit Extension
//
//  Created by Leo Dion on 8/28/19.
//  Copyright © 2019 BrightDigit. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {
  
  override func awake(withContext context: Any?) {
    super.awake(withContext: context)
    
    // Configure interface objects here.
    let webSocketTask = URLSession.shared.webSocketTask(with: URL(string: "wss://echo.websocket.org")!)
    webSocketTask.resume()
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
