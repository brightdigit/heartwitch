//
//  HeartwitchView.swift
//  Heartwitch-watchOS-app WatchKit Extension
//
//  Created by Leo Dion on 9/3/19.
//  Copyright © 2019 BrightDigit. All rights reserved.
//

import SwiftUI
import Heartwitch

struct HeartwitchView: View {
  @EnvironmentObject var object : HeartwitchObject
  
  var body: some View {
    ZStack{
      ZStack{
        acquiringConnectionView
        beginMonitoringView
        heartRateView
      }
    }
  }
  
  var acquiringConnectionView : some View {
    let hasNoConnection : Void?
    if self.object.socketConfiguration == nil && self.object.timer == nil {
     hasNoConnection = Void()
    } else {
      hasNoConnection = nil
    }
    return hasNoConnection.map{ Text("Getting Connection Info...").onAppear {
           self.object.acquireSocketConfiguration()
         }
    }
  }
  
  var beginMonitoringView : some View {
    let socketConfiguration : SocketConfiguration?
    if self.object.timer == nil {
      socketConfiguration = self.object.socketConfiguration
    } else {
      socketConfiguration = nil
    }
    return socketConfiguration.map{
      _ in
      Text("Waiting For Heart Rate...").onAppear(perform: self.object.beginMonitoring)
    }
  }
  
  var heartRateView : some View {
    self.object.workoutData?.heartRate.map{
      Text("\($0)")
    }
  }
}

struct HeartwitchView_Previews: PreviewProvider {
  static var previews: some View {
    HeartwitchView()
  }
}
