import Fluent
import Vapor
import Heartwitch

extension UUID : LosslessStringConvertible {
  public init?(_ description: String) {
    guard let value = UUID(uuidString: description) else {
      return nil
    }
    
    self = value
  }
}
final class WorkoutController {
  let db: Database
  
  init(db: Database) {
    self.db = db
  }
  
  func create(req: Request) throws -> EventLoopFuture<Workout> {
    let workout = Workout(id: UUID())
    return workout.save(on: db).map{
      return workout
    }
  }
  
  func put(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
    let workout = Workout.find(req.parameters.get("workoutID"), on: db).unwrap(or: Abort(HTTPResponseStatus.notFound))
    let data = try req.content.decode(WorkoutData.self)
    
    return workout.and(value: data).flatMap { (arg)  in
      let (workout, data) = arg
      var didChange = false
      if let heartRate = data.heartRate {
        workout.heartRate = heartRate
        didChange = true
      }
      if didChange {
        return workout.update(on: self.db).transform(to: HTTPStatus.accepted)
      } else {
        return self.db.eventLoop.future(HTTPStatus.noContent)
      }
    }
  }
  
  func webSocket(_ req: Request, _ wss: WebSocket) {
    let workout = Workout.find(req.parameters.get("workoutID"), on: db)
    
    _ = workout.map { (workout) in
      if let id = workout.flatMap({ try? $0.requireID() }){
        WebSocketService.shared.save(wss, withID: id)
      }
      
    }
  }
  //
  //  func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
  //    return Todo.find(req.parameters.get("todoID"), on: self.db)
  //      .unwrap(or: Abort(.notFound))
  //      .flatMap { $0.delete(on: self.db) }
  //      .transform(to: .ok)
  //  }
}
