//
//  ContentView.swift
//  heartwitch-watchOS-app Extension
//
//  Created by Leo Dion on 8/27/19.
//

import SwiftUI
import WatchConnectivity

class SessionManager : NSObject, ObservableObject, WCSessionDelegate {
  @Published var session : WCSession? {
    didSet {
      self.objectWillChange.send()
    }
  }
  @Published var identifier : UUID? {
    didSet {
      print("indentified")
      self.objectWillChange.send()
    }
  }
  func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    switch (activationState) {
    case .activated:
      self.session = session
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
    self.identifier = uuid
    replyHandler(Data())
  }
  
  
}

struct ContentView: View {
  @ObservedObject var sessionManager = SessionManager()
  
  var body: some View {
    ZStack{
      sessionManager.identifier.map{_ in
        Text("Connected")
      }
      Text("Connecting...")
    }
    
  }
  
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
