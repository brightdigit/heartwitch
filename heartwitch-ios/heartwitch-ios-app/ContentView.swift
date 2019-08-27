//
//  ContentView.swift
//  heartwitch-ios-app
//
//  Created by Leo Dion on 7/11/19.
//

import SwiftUI
import Network
import WatchConnectivity

var globalConnection : NWConnection?
var sourceTimer : DispatchSourceTimer?

let jsonEncoder = JSONEncoder()

class SessionManager : NSObject, ObservableObject, WCSessionDelegate {
  @Published var session : WCSession? {
    didSet {
      self.objectWillChange.send()
    }
  }
  
  @Published var identifer : UUID? {
    didSet {
      self.objectWillChange.send()
    }
  }
  
  var connectable : Bool {
    return self.session != nil && self.identifer == nil
  }
  func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    switch (activationState) {
    case .activated:
      self.session = session
    case .notActivated:
      self.session = nil
    case .inactive:
      self.session = nil
    @unknown default:
      self.session = nil
    }
    
  }
  
  
  
  func sessionDidBecomeInactive(_ session: WCSession) {
    self.session = nil
  }
  
  func sessionDidDeactivate(_ session: WCSession) {
    self.session = nil
  }
  
  public func postIdentifier(_ identifier: UUID) {
    let data = withUnsafePointer(to: identifier) {
        Data(bytes: $0, count: MemoryLayout.size(ofValue:  identifier))
    }
    
    self.session!.sendMessageData(data, replyHandler: { (_) in
      self.identifer = identifier
    }) { (error) in
      print(error)
    }
  }
  
  override init () {
    super.init()
    if WCSession.isSupported() {
      WCSession.default.delegate = self
      WCSession.default.activate()
    }
  }
}
struct ContentView : View {
  @State var id: String = ""
  @ObservedObject var sessionManager = SessionManager()
  
  func beginConnect (){
    if let identifier = UUID(uuidString: id) {
      self.sessionManager.postIdentifier(identifier)
    }
//    WCSession.default.sendMessage(["identifer": self.id], replyHandler: { (response) in
//
//    }) { (error) in
//
//    }
//    guard let uuid = UUID(uuidString: self.id) else {
//      return
//    }
//    guard let url = URL(string: "ws://localhost:8080/workouts/\(uuid)/run") else {
//      return
//    }
//    let task = URLSession.shared.webSocketTask(with: url)
//
//    task.resume()
//    let source = DispatchSource.makeTimerSource()
//
//    source.setEventHandler {
//      let wkData = WorkoutData(heartRate: Double.random(in: 70...160))
//      if let data = try? jsonEncoder.encode(wkData) {
//
//        task.send(.data(data)) { (error) in
//          print(error)
//        }
//      }
//    }
//    source.schedule(deadline: .now(), repeating: 5)
//    source.activate()
//    sourceTimer = source
  }
  
  
  
  var body: some View {
    VStack{
      TextField("Enter the UUID", text: $id)
      Button(action: self.beginConnect) {
        Text("Connect")
      }
    }
  }
  
  var connectedView : some View {
    sessionManager.identifer.map{_ in
      Text("Connected")
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
