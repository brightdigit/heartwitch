//
//  Heartwitch.swift
//  App
//
//  Created by Leo Dion on 9/1/19.
//

import Foundation

public struct WorkoutData : Codable {
  public var heartRate : Double?
  
  public init (heartRate: Double?) {
    self.heartRate = heartRate
  }
}
