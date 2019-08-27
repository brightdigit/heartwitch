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

let jsonEncoder = JSONEncoder()
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
      let wkData = WorkoutData(heartRate: Double.random(in: 70...160))
      if let data = try? jsonEncoder.encode(wkData) {
        
        task.send(.data(data)) { (error) in
          print(error)
        }
      }
    }
    source.schedule(deadline: .now(), repeating: 5)
    source.activate()
    sourceTimer = source
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
