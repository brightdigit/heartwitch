//
//  HeartwitchObject.swift
//  Heartwitch-watchOS-app WatchKit Extension
//
//  Created by Leo Dion on 9/3/19.
//  Copyright © 2019 BrightDigit. All rights reserved.
//

import Foundation
import Heartwitch


struct WorkoutResponse : Codable {
  let id : String
}

public class HeartwitchObject : ObservableObject {
  let jsonEncoder = JSONEncoder()
  @Published var timer : Timer? = nil
  @Published var workoutData : WorkoutData? = nil
  @Published var shortID : String = ""
  @Published var fullIdentifier : String? = nil
  
  //  lazy var ckDatabase = CKContainer(identifier: "iCloud.com.brightdigit.Heartwitch").privateCloudDatabase
  
  //  fileprivate func saveNewSubscriptions(toDatabase database: CKDatabase) {
  //    let subscription = CKQuerySubscription(recordType: "Workout", predicate: .init(value: true), options: [.firesOnRecordCreation])
  //
  //    let notificationInfo = CKSubscription.NotificationInfo()
  //    notificationInfo.shouldSendContentAvailable = true
  //    notificationInfo.alertBody = "New Workout Ready"
  //    notificationInfo.alertLocalizationKey = "New artwork by your favorite artist.";
  //    notificationInfo.shouldBadge = true
  //
  //    //notificationInfo.desiredKeys = ["hostName", "identifier"]
  //
  //    subscription.notificationInfo = notificationInfo
  //    database.save(subscription) { (subscription, error) in
  //      debugPrint(subscription, error)
  //    }
  //  }
  
  //  public func acquireSocketConfiguration () {
  //
  //    ckDatabase.fetchAllSubscriptions { (subscriptions, error) in
  //      if let subscriptions = subscriptions {
  //        let group = DispatchGroup()
  //        for subscription in subscriptions {
  //          group.enter()
  //          self.ckDatabase.delete(withSubscriptionID: subscription.subscriptionID) { (id, error) in
  //            debugPrint("subscription-del:", id ?? error)
  //            group.leave()
  //          }
  //        }
  //        group.notify(queue: .main) {
  //          self.saveNewSubscriptions(toDatabase: self.ckDatabase)
  //        }
  //      }
  //      if (subscriptions?.count ?? 0) < 1 {
  //        self.saveNewSubscriptions(toDatabase: self.ckDatabase)
  //      }
  //    }
  //    let query = CKQuery(recordType: "Workout", predicate: NSPredicate(value: true))
  //    query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
  //
  //    ckDatabase.perform(query, inZoneWith: nil) { (records, error) in
  //      if let record = records?.first {
  //
  //        let identifierData = record["identifier"] as? Data
  //
  //        let identifierOpt : UUID? = identifierData.map{
  //          let bytes = [UInt8]($0)
  //          return NSUUID(uuidBytes: bytes) as UUID
  //        }
  //
  //        guard let identifier = identifierOpt else {
  //          return
  //        }
  //
  //        guard let hostName = record["hostName"] as? String else {
  //          return
  //        }
  //        DispatchQueue.main.async {
  //
  //          debugPrint("socket ready", hostName, identifier)
  //          self.socketConfiguration = .init(identifier: identifier, hostName: hostName)
  //        }
  //
  //      }
  //
  //    }
  
  //    UNUserNotificationCenter.current().delegate = self
  //    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge]) { (granted, error) in
  //      debugPrint("request", error ?? granted)
  //    }
  //    WKExtension.shared().registerForRemoteNotifications()
  // }
  public func beginMonitoring () {
    guard !(self.shortID.isEmpty) else {
      return
    }
    
    let hostName = ProcessInfo.processInfo.environment["hostName"] ?? "http://localhost:8080"
    guard let url = URL(string: "\(hostName)/api/v1/workouts/\(shortID)") else {
      return
    }
    let jsonDecoder = JSONDecoder()
    debugPrint(url)
    URLSession.shared.dataTask(with: url) { (data, _, error) in
      guard let data = data else {
        return
      }
      guard let response = try? jsonDecoder.decode(WorkoutResponse.self, from: data) else {
        return
      }
      guard let url = URL(string: "\(hostName)/api/v1/workouts/\(response.id)") else {
        return
      }
      
      DispatchQueue.main.async {
        self.fullIdentifier = response.id
        let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (_) in
          let wkData = WorkoutData(heartRate: Double.random(in: 70...160))
          var urlRequest = URLRequest(url: url)
          urlRequest.httpMethod = "PUT"
          urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
          
          if let data = try? self.jsonEncoder.encode(wkData) {
            
            urlRequest.httpBody = data
            let task = URLSession.shared.dataTask(with: urlRequest)
            task.resume()
            
            DispatchQueue.main.async {
              self.workoutData = wkData
            }
          }
        }
        timer.fire()
        self.timer = timer
      }
    }.resume()
    
    
  }
}
