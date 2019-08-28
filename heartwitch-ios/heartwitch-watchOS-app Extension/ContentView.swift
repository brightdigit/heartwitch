//
//  ContentView.swift
//  heartwitch-watchOS-app Extension
//
//  Created by Leo Dion on 8/27/19.
//

import SwiftUI
import WatchConnectivity
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
  var session : WCSession?
  var handler : SessionHandlerProtocol?
  func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    switch (activationState) {
    case .activated:
      self.session = session
      DispatchQueue.main.async {
        self.handler?.state = .activated
      }
      
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
    DispatchQueue.main.async {
      self.handler?.state = .identified(uuid)
    }
    
    print(uuid)
    replyHandler(Data())
  }
  
  
}

class SessionTimer : NSObject, URLSessionWebSocketDelegate {
  var identifier : UUID?
  var timer : Timer?
  var websocketTask : URLSessionWebSocketTask?
  var session : URLSession!
  let queue = OperationQueue()
  
  override init () {
    super.init()
    self.session = URLSession(configuration: .default, delegate: self, delegateQueue: .main)
  }
  
  func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
    self.timer = Timer(fire: Date(timeIntervalSinceNow: 5.0), interval: 1.0, repeats: true, block: self.onTimer)
//        let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (_) in
//          let wkData = WorkoutData(heartRate: Double.random(in: 70...160))
//          print(wkData.heartRate)
////          if let task = self.websocketTask, let data = try? jsonEncoder.encode(wkData) {
////
////            task.send(.data(data)) { (error) in
////              print(error)
////            }
////          }
//        }
    //self.timer = timer
  }
  
  func onTimer (_ timer : Timer) {
              let wkData = WorkoutData(heartRate: Double.random(in: 70...160))
              print(wkData.heartRate)
  }
  func beginUpdates (identifier : UUID) {
    guard let url = URL(string: "ws://localhost:8080/workouts/\(identifier)/run") else {
      return
    }
    let task = self.session.webSocketTask(with: url)
    
    self.websocketTask = task
    task.resume()
    
//    let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (_) in
//      let wkData = WorkoutData(heartRate: Double.random(in: 70...160))
//      print(wkData.heartRate)
//      if let task = self.websocketTask, let data = try? jsonEncoder.encode(wkData) {
//
//        task.send(.data(data)) { (error) in
//          print(error)
//        }
//      }
//    }
//    let source = DispatchSource.makeTimerSource()
//
//    source.setEventHandler {
//      let wkData = WorkoutData(heartRate: Double.random(in: 70...160))
//      if let task = self.websocketTask, let data = try? jsonEncoder.encode(wkData) {
//
//        task.send(.data(data)) { (error) in
//          print(error)
//        }
//      }
//    }
//    source.schedule(deadline: .now(), repeating: 5)
//    source.activate()
    
  }
}

struct ContentView: View {
  @ObservedObject var sessionHandler = SessionHandler()
  let timer = SessionTimer()
  var body: some View {
    ZStack {
      activatedView
      connectingView
      identifiedView
    }
    //    switch sessionHandler.state {
    //    case .activated:
    //      return Text("Activated")
    //    case .connecting:
    //      return Text("connecting")
    //    case .identified:
    //      return Text("identified").onAppear(perform: beginUpdates)
    //    }
    
  }
  
  var activatedView : some View {
    (sessionHandler.state == SessionState.activated ? sessionHandler.state : nil ).map { (_) in
      Text("Activated")
    }
    
  }
  
  var connectingView : some View {
    (sessionHandler.state == SessionState.connecting ? sessionHandler.state : nil ).map { (_) in
      Text("connecting")
    }
  }
  
  var identifiedView : some View {
    var identifier : UUID? = nil
    if case let .identified(id) = sessionHandler.state {
      identifier = id
    }
    return (identifier).map { (_) in
      Text("identified").onAppear(perform: self.beginUpdates)
    }
  }
  
  func beginUpdates () {
    guard case let .identified(uuid) = sessionHandler.state else {
      return
    }
    self.timer.beginUpdates(identifier: uuid)
    
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
