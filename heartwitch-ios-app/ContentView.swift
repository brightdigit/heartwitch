//
//  ContentView.swift
//  heartwitch-ios-app
//
//  Created by Leo Dion on 7/11/19.
//

import SwiftUI
import Network

struct ContentView : View {
  var connection : NWConnection?
  @State var id: String = "" {
    didSet {
      guard let uuid = UUID(uuidString: self.id) else {
        return
      }
      guard let url = URL(string: "ws://localhost:8080/workouts/\(uuid)/run") else {
        return
      }
      let endPoint = NWEndpoint.url(url)
      let connection = NWConnection(to: endPoint, using: .tcp)
//      self.connection = NWConnection(host: "echo.websocket.org", port: 443, using: .tls)
//
      connection.stateUpdateHandler = { state in
        print("State:", state)
        switch state {
        case .ready:
          self.connectionReady(connection)
        default:
          break
        }
      }
     connection.start(queue: .main)
    }
  }
  
  func connectionReady(_ connection: NWConnection) {
    connection.se
  }
  var body: some View {
    TextField("Enter the UUID", text: $id)
  }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
#endif
