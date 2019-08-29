//
//  ContentView.swift
//  heartwitch-watchOS-app Extension
//
//  Created by Leo Dion on 8/27/19.
//

import SwiftUI
import WatchConnectivity
let jsonEncoder = JSONEncoder()
let jsonDecoder = JSONDecoder()

struct WorkoutData : Codable {
  var heartRate : Double?
}
struct SocketConfiguration : Codable, Equatable {
  let identifier : UUID
  let hostName : String
}
enum SessionState : Equatable {
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
  
  static let global = SessionTimer()
  override init () {
    print("making timer")
    super.init()
    
  }
//
//  func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
//
//  }
//
//  func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
//
//  }
//
//  func urlSession(_ session: URLSession, taskIsWaitingForConnectivity task: URLSessionTask) {
//
//  }
//
//  func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
//
//  }
//
//  func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
//
//  }
//
//  func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
//
//  }
//
//  func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
//
//  }
//
//  func urlSession(_ session: URLSession, task: URLSessionTask, needNewBodyStream completionHandler: @escaping (InputStream?) -> Void) {
//
//  }
//
//  func urlSession(_ session: URLSession, task: URLSessionTask, willBeginDelayedRequest request: URLRequest, completionHandler: @escaping (URLSession.DelayedRequestDisposition, URLRequest?) -> Void) {
//
//  }
//
//  func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
//
//  }
//
//  func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
//
//  }
//
//  func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
//
//  }
//
//
//  func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
//    print("beginning timer", webSocketTask)
//
//    //self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: self.onTimer)
////        let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (_) in
////          let wkData = WorkoutData(heartRate: Double.random(in: 70...160))
////          print(wkData.heartRate)
//////          if let task = self.websocketTask, let data = try? jsonEncoder.encode(wkData) {
//////
//////            task.send(.data(data)) { (error) in
//////              print(error)
//////            }
//////          }
////        }
//    //self.timer = timer
//  }
  
  
  
  func onTimer (_ timer : Timer) {
              let wkData = WorkoutData(heartRate: Double.random(in: 70...160))
              print(wkData.heartRate)
  }
  func beginUpdates (configuration : SocketConfiguration) {
    print("beginning Updates")
    guard let url = URL(string: "http://\(configuration.hostName)/workouts/\(configuration.identifier)") else {
      return
    }
//    print("starting websocket")
//    let task = self.session.webSocketTask(with: url)
//    print("init websocket")
//
//    self.websocketTask = task
//    task.resume()
//    print("started websocket")
        self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: self.onTimer)
            let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (_) in
              let wkData = WorkoutData(heartRate: Double.random(in: 70...160))
              var urlRequest = URLRequest(url: url)
              urlRequest.httpMethod = "PUT"
              urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
              print(wkData.heartRate)
              if let data = try? jsonEncoder.encode(wkData) {

                urlRequest.httpBody = data
                let task = URLSession.shared.dataTask(with: urlRequest)
                task.resume()
              }
            }
        self.timer = timer
    
  }
}

struct ContentView: View {
  @ObservedObject var sessionHandler = SessionHandler.global
  
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
    var configuration : SocketConfiguration? = nil
    if case let .configured(newConfiguration) = sessionHandler.state {
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
    
    SessionTimer.global.beginUpdates(configuration: configuration)
    
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
