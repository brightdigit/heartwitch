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
enum SessionState : Equatable {
  case connecting, activated, identified(UUID)
}


protocol SessionHandlerProtocol {
  var state : SessionState { set get }
}
class SessionHandler : ObservableObject, SessionHandlerProtocol {
  @Published var state = SessionState.connecting
  let manager = SessionManager()
  
  init () {
    self.manager.handler = self
  }
  
}
class SessionManager : NSObject, WCSessionDelegate {
  func sessionDidBecomeInactive(_ session: WCSession) {
    
  }
  
  func sessionDidDeactivate(_ session: WCSession) {
    
  }
  
  var session : WCSession?
  var handler : SessionHandlerProtocol?
  func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    switch (activationState) {
    case .activated:
      self.session = session
      self.handler?.state = .activated
      print("activated")
    case .notActivated:
      self.session = nil
    case .inactive:
      self.session = nil
    @unknown default:
      self.session = nil
    }
    
  }
  
  
  override init () {
    super.init()
    if WCSession.isSupported() {
      print("activating")
      WCSession.default.delegate = self
      WCSession.default.activate()
      
    }
  }
  
  func session(_ session: WCSession, didReceiveMessageData messageData: Data, replyHandler: @escaping (Data) -> Void) {
    
    
    var bytes = [UInt8].init(repeating: 0, count: messageData.count)
    messageData.copyBytes(to: &bytes, count: messageData.count)
    let uuid = NSUUID(uuidBytes: bytes) as UUID
      //self.identifier = uuid
    self.handler?.state = .identified(uuid)
    print(uuid)
    replyHandler(Data())
  }
  
  public func postIdentifier(_ identifier: UUID) {
    let data = withUnsafePointer(to: identifier) {
        Data(bytes: $0, count: MemoryLayout.size(ofValue:  identifier))
    }
    
    self.session!.sendMessageData(data, replyHandler: { (_) in
      self.handler?.state = .identified(identifier)
    }) { (error) in
      print(error)
    }
  }
}
struct ContentView : View {
  @State var id: String = ""
  
  func beginConnect (){
    if let identifier = UUID(uuidString: id) {
      self.sessionHandler.manager.postIdentifier(identifier)
    }
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
  //}
  
  
  
  @ObservedObject var sessionHandler = SessionHandler()
  var body: some View {
    VStack{
      stateView
      TextField("Enter the UUID", text: $id)
      Button(action: self.beginConnect) {
        Text("Connect")
      }.disabled(self.sessionHandler.state != SessionState.activated)
    }
    
  }
  var stateView : some View {
    
    switch sessionHandler.state {
    case .activated:
      return Text("Activated")
    case .connecting:
      return Text("connecting")
    case .identified:
      return Text("identified")
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
