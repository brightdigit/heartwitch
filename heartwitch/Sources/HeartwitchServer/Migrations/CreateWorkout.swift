import Fluent

struct CreateWorkout: Migration {
  func prepare(on database: Database) -> EventLoopFuture<Void> {
    return database.schema("workouts")
      .field("id", .uuid, .identifier(auto: true))
      .field("heartRate", .double)
      .field("createdAt", .date)
      .field("updatedAt", .date)
      .create()
  }
  
  func revert(on database: Database) -> EventLoopFuture<Void> {
    return database.schema("workouts").delete()
  }
}
