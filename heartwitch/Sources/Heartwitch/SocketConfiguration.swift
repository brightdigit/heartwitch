//
//  File.swift
//  
//
//  Created by Leo Dion on 9/1/19.
//

import Foundation

public struct SocketConfiguration : Codable, Equatable {
  public let identifier : UUID
  public let hostName : String
  
  public init (identifier: UUID, hostName: String) {
    self.identifier = identifier
    self.hostName = hostName
  }
}
