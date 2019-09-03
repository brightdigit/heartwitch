//
//  HostingController.swift
//  heartwitch-watchOS-app Extension
//
//  Created by Leo Dion on 8/27/19.
//

import WatchKit
import Foundation
import SwiftUI

class HostingController: WKHostingController<AnyView> {
  
  override var body: AnyView {
    return AnyView(ContentView().environmentObject(WorkoutObject()))
  }
}
