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
let jsonDecoder = JSONDecoder()
enum SessionState : Equatable {
  case connecting, activated, configured(SocketConfiguration)
}

struct SocketConfiguration : Codable, Equatable {
  let identifier : UUID
  let hostName : String
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
    
    let configuration = try! jsonDecoder.decode(SocketConfiguration.self, from: messageData)
      //self.identifier = uuid
    self.handler?.state = .configured(configuration)
    
    replyHandler(Data())
  }
  
  public func postConfiguration(_ configuration: SocketConfiguration) {
    let data = try! jsonEncoder.encode(configuration)
    
    
    self.session!.sendMessageData(data, replyHandler: { (_) in
      self.handler?.state = .configured(configuration)
    }) { (error) in
      print(error)
    }
  }
}
struct ContentView : View, ScanningListener {

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
  @State var showImagePicker: Bool = false
  var body: some View {
    ZStack{
    VStack{
      stateView
      //TextField("Enter the UUID", text: $id)
//      Button(action: self.beginConnect) {
//        Text("Connect")
//      }.disabled(self.sessionHandler.state != SessionState.activated)
      
      Button(action:
      self.scanQR) {
        Image(systemName: "qrcode.viewfinder").imageScale(.large)
      }.disabled(self.sessionHandler.state != SessionState.activated)
    }
    if (showImagePicker) {
      ScannerView().onScan(self)
    }
    }
    
  }
  
  func scanQR () {
    showImagePicker.toggle()
  }
  
  func controller(_ controller: ScannerViewController, scanned result: Result<SocketConfiguration, Error>) {
        switch result {
    case .success(let configuration):
      self.sessionHandler.manager.postConfiguration(configuration)
      self.showImagePicker.toggle()
    case .failure(let error):
      print(error)
    }
  }
  var stateView : some View {
    
    switch sessionHandler.state {
    case .activated:
      return Text("Activated")
    case .connecting:
      return Text("connecting")
    case .configured:
      return Text("configured")
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
