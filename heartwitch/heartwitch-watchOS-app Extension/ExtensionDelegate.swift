//
//  ExtensionDelegate.swift
//  heartwitch-watchOS-app Extension
//
//  Created by Leo Dion on 8/27/19.
//

import WatchKit
import CloudKit
import UserNotifications
import Foundation

class ExtensionDelegate: NSObject, WKExtensionDelegate, UNUserNotificationCenterDelegate {
  
  fileprivate func saveNewSubscriptions(toDatabase database: CKDatabase) {
    let subscription = CKQuerySubscription(recordType: "Workout", predicate: .init(value: true), options: [.firesOnRecordCreation])
    
    let notificationInfo = CKSubscription.NotificationInfo()
    notificationInfo.shouldSendContentAvailable = true
    notificationInfo.alertBody = "New Workout Ready"
    notificationInfo.alertLocalizationKey = "New artwork by your favorite artist.";
    notificationInfo.shouldBadge = true
    
    subscription.notificationInfo = notificationInfo
    database.save(subscription) { (subscription, error) in
      debugPrint(subscription, error)
    }
  }
  
  func applicationDidFinishLaunching() {
    // Perform any final initialization of your application.
    let database = CKContainer(identifier: "iCloud.com.brightdigit.Heartwitch").privateCloudDatabase
    database.fetchAllSubscriptions { (subscriptions, error) in
      if let subscriptions = subscriptions {
        let group = DispatchGroup()
        for subscription in subscriptions {
          group.enter()
          database.delete(withSubscriptionID: subscription.subscriptionID) {_,_ in
            group.leave()
          }
        }
        group.notify(queue: .main) {
          self.saveNewSubscriptions(toDatabase: database)
        }
      }
      if (subscriptions?.count ?? 0) < 1 {
        self.saveNewSubscriptions(toDatabase: database)
        
      }
    }
    let query = CKQuery(recordType: "Workout", predicate: NSPredicate(value: true))
    query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
    
    database.perform(query, inZoneWith: nil) { (records, error) in
      if let record = records?.first {
        print(record["identifier"] )
        let identifierData = record["identifier"] as? Data
        
        let identifier : UUID? = identifierData.map{
          let bytes = [UInt8]($0)
          return NSUUID(uuidBytes: bytes) as UUID
        }
        
        print(identifier)
      }
      
    }
    UNUserNotificationCenter.current().delegate = self
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge]) { (granted, error) in
      debugPrint("request", error ?? granted)
    }
    WKExtension.shared().registerForRemoteNotifications()
  }
  
  func applicationDidBecomeActive() {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }
  
  func applicationWillResignActive() {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, etc.
  }
  
  func didRegisterForRemoteNotifications(withDeviceToken deviceToken: Data) {
    debugPrint("deviceToken", deviceToken)
  }
  
  func didFailToRegisterForRemoteNotificationsWithError(_ error: Error) {
    debugPrint("error",error)
  }
  
  func didReceiveRemoteNotification(_ userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (WKBackgroundFetchResult) -> Void) {
    debugPrint(userInfo)
  }
  
  
  
  func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
    // Sent when the system needs to launch the application in the background to process tasks. Tasks arrive in a set, so loop through and process each one.
    for task in backgroundTasks {
      // Use a switch statement to check the task type
      switch task {
      case let backgroundTask as WKApplicationRefreshBackgroundTask:
        // Be sure to complete the background task once you’re done.
        backgroundTask.setTaskCompletedWithSnapshot(false)
      case let snapshotTask as WKSnapshotRefreshBackgroundTask:
        // Snapshot tasks have a unique completion call, make sure to set your expiration date
        snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
      case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
        // Be sure to complete the connectivity task once you’re done.
        connectivityTask.setTaskCompletedWithSnapshot(false)
      case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
        // Be sure to complete the URL session task once you’re done.
        urlSessionTask.setTaskCompletedWithSnapshot(false)
      case let relevantShortcutTask as WKRelevantShortcutRefreshBackgroundTask:
        // Be sure to complete the relevant-shortcut task once you're done.
        relevantShortcutTask.setTaskCompletedWithSnapshot(false)
      case let intentDidRunTask as WKIntentDidRunRefreshBackgroundTask:
        // Be sure to complete the intent-did-run task once you're done.
        intentDidRunTask.setTaskCompletedWithSnapshot(false)
      default:
        // make sure to complete unhandled task types
        task.setTaskCompletedWithSnapshot(false)
      }
    }
  }
  
  func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    print(notification)
  }
  
  func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    print(response)
  }
}
