//
//  ContentView.swift
//  heartwitch-watchOS-app Extension
//
//  Created by Leo Dion on 8/27/19.
//

import SwiftUI
import WatchConnectivity
import Heartwitch

let jsonEncoder = JSONEncoder()
let jsonDecoder = JSONDecoder()



enum SessionState : Equatable  {
  case connecting, activated, configured(SocketConfiguration)
}


protocol SessionHandlerProtocol {
  var state : SessionState { set get }
}
class SessionHandler : ObservableObject, SessionHandlerProtocol {
  @Published var state = SessionState.connecting
  let manager = SessionManager()
  
  private init () {
    print("making handler")
    self.manager.handler = self
  }
  
  static let global = SessionHandler()
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
    print("making manager")
    super.init()
    if WCSession.isSupported() {
      print("activating")
      WCSession.default.delegate = self
      WCSession.default.activate()
      
    }
  }
  
  func session(_ session: WCSession, didReceiveMessageData messageData: Data, replyHandler: @escaping (Data) -> Void) {
    
    let configuration = try! jsonDecoder.decode(SocketConfiguration.self, from: messageData)
    //self.identifier = uuid
    DispatchQueue.main.async {
      self.handler?.state = .configured(configuration)
    }
    
    print(configuration)
    replyHandler(Data())
  }
  
  
}

class SessionTimer : NSObject, URLSessionWebSocketDelegate {
  var identifier : UUID?
  var timer : Timer?
  var workout : WorkoutObject?
  static let global = SessionTimer()
  override init () {
    print("making timer")
    super.init()
    
  }
  
  func beginUpdates (configuration : SocketConfiguration, with workout: WorkoutObject) {
    print("beginning Updates")
    guard let url = URL(string: "http://\(configuration.hostName)/workouts/\(configuration.identifier)") else {
      return
    }
    self.workout = workout
    
    let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (_) in
      let wkData = WorkoutData(heartRate: Double.random(in: 70...160))
      var urlRequest = URLRequest(url: url)
      urlRequest.httpMethod = "PUT"
      urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
      
      if let workout = self.workout, let data = try? jsonEncoder.encode(wkData) {
        
        urlRequest.httpBody = data
        let task = URLSession.shared.dataTask(with: urlRequest)
        task.resume()
        workout.workoutData = wkData
      }
    }
    self.timer = timer
    
  }
}

class WorkoutObject : ObservableObject {
  @Published var workoutData : WorkoutData? = nil
  
  
}
struct ContentView: View {
  @ObservedObject var sessionHandler = SessionHandler.global
  @EnvironmentObject var workout : WorkoutObject
  var body: some View {
    ZStack {
      activatedView
      connectingView
      identifiedView
      workoutView
    }
    
  }
  
  var workoutView : some View {
    workout.workoutData?.heartRate.map{
      Text("\($0)")
    }
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
    var configuration : SocketConfiguration? = nil
    if case let .configured(newConfiguration) = sessionHandler.state, workout.workoutData?.heartRate == nil {
      configuration = newConfiguration
    }
    return (configuration).map { (_) in
      Text("identified").onAppear(perform: self.beginUpdates)
    }
  }
  
  func beginUpdates () {
    guard case let .configured(configuration) = sessionHandler.state else {
      return
    }
    
    SessionTimer.global.beginUpdates(configuration: configuration, with: workout)
    
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
