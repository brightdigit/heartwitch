//
//  ContentView.swift
//  heartwitch-ios-app
//
//  Created by Leo Dion on 7/11/19.
//

import SwiftUI
import Network

var globalConnection : NWConnection?
var sourceTimer : DispatchSourceTimer?
struct ContentView : View {
  @State var id: String = ""
  
  func beginConnect (){
    
    guard let uuid = UUID(uuidString: self.id) else {
      return
    }
    guard let url = URL(string: "ws://localhost:8080/workouts/\(uuid)/run") else {
      return
    }
    let task = URLSession.shared.webSocketTask(with: url)
    
    task.resume()
    let source = DispatchSource.makeTimerSource()
       
       source.setEventHandler {
        task.send(.data(UUID().uuidString.data(using: .utf8)!)) { (error) in
          print(error)
        }
       }
       source.schedule(deadline: .now(), repeating: 5)
       source.activate()
       sourceTimer = source
//    let endPoint = NWEndpoint.url(url)
//    let connection = NWConnection(to: endPoint, using: .tcp)
//    //      self.connection = NWConnection(host: "echo.websocket.org", port: 443, using: .tls)
//    //
//    connection.stateUpdateHandler = { state in
//      print("State:", state)
//      switch state {
//      case .ready:
//        self.connectionReady(connection)
//      default:
//        break
//      }
//    }
//    connection.start(queue: .main)
//    globalConnection = connection
  }
  
  
  func connectionReady(_ connection: NWConnection) {
   
  }
  
  var body: some View {
    VStack{
      TextField("Enter the UUID", text: $id)
      Button(action: self.beginConnect) {
        Text("Connect")
      }
    }
  }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
#endif
