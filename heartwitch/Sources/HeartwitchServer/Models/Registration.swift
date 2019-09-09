//
//  File.swift
//  
//
//  Created by Leo Dion on 9/9/19.
//

import Vapor
import Fluent

final class Registration : Model, Content {
  init() {}
  static let schema = "Registrations"
  
  @ID(key: "id")
  var id: UUID?
  
  @Field(key: "emailAddress")
  public var emailAddress: String
  
  @Timestamp(key: "createdAt", on: .create)
  var createdAt: Date?
  
  @Timestamp(key: "updatedAt", on: .update)
  var updatedAt: Date?
  
  init(id: UUID?, emailAddress : String) {
    self.id = id
    self.emailAddress = emailAddress
  }
}
