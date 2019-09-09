import Fluent

//@available(*, deprecated)
//struct CreateWorkout: Migration {
//  func prepare(on database: Database) -> EventLoopFuture<Void> {
//    return database.schema("workouts")
//      .field("id", .uuid, .identifier(auto: false))
//      .field("heartRate", .double)
//      .field("createdAt", .date)
//      .field("updatedAt", .date)
//      .create()
//  }
//  
//  func revert(on database: Database) -> EventLoopFuture<Void> {
//    return database.schema("workouts").delete()
//  }
//}

struct CreateRegistration : Migration {
  func prepare(on database: Database) -> EventLoopFuture<Void> {
    return database.schema("Registrations")
      .field("id", .uuid, .identifier(auto: true))
      .field("emailAddress", .string)
      .field("createdAt", .date)
      .field("updatedAt", .date)
      .unique(on: "emailAddress")
      .create()
  }
  
  func revert(on database: Database) -> EventLoopFuture<Void> {
    return database.schema("Registrations").delete()
  }
}
