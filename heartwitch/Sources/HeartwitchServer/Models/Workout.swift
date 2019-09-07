import Fluent
import Vapor
import Heartwitch
import Base32Crockford

struct WorkoutResponse : Content {
  let id : String
  
  init?(workout: Workout) {
    guard let id = workout.id else {
      return nil
    }
    let bytes = ByteCollection(uuid: id)
    let data = Data(bytes)
    let idString = Base32CrockfordEncoding.encoding.encode(data: data)
    self.id = idString
  }
}

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
    
    webSocket.send(text, mask: false)
    
    return database.eventLoop.future()
  }
  
}
