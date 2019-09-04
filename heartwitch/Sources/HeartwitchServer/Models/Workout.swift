import Fluent
import Vapor
import Heartwitch

final class Workout: Model, Content {
  static let schema = "workouts"
  
  static let jsonEncoder = JSONEncoder()
  
  @ID(key: "id")
  var id: UUID?
  
  @Field(key: "heartRate")
  var heartRate: Double?
  
  @Timestamp(key: "createdAt", on: .create)
  var createdAt: Date?
  
  @Timestamp(key: "updatedAt", on: .update)
  var updatedAt: Date?
  
  init() { }
  
  init(id: UUID? = nil, heartRate: Double? = nil) {
    self.id = id
    self.heartRate = heartRate
    
  }
  
  func didUpdate(on database: Database) -> EventLoopFuture<Void> {
    guard let id = self.id else {
      return database.eventLoop.future(error: Abort(.internalServerError))
    }
    
    guard let webSocket = WebSocketService.shared.get(webSocketWithId: id) else {
      return database.eventLoop.future(error: Abort(HTTPResponseStatus.notFound))
    }
    
    guard let heartRate = self.heartRate else {
      return webSocket.eventLoop.future()
    }
    
    let data : Data
    let workoutData = WorkoutData(heartRate: heartRate)
    do {
      data = try Workout.jsonEncoder.encode(workoutData)
    } catch let error {
      return webSocket.eventLoop.future(error: error)
    }
    
    guard let text = String(data: data, encoding: .utf8) else {
      return webSocket.eventLoop.future(error: Abort(.internalServerError))
    }
    debugPrint(text)
    let promise = webSocket.eventLoop.makePromise(of: Void.self)
    webSocket.send(text, promise: promise)
    
    return promise.futureResult
  }
  
}
