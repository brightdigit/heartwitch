import Vapor
import Heartwitch
import Base32Crockford

struct WorkoutResponse : Content {
  let id : String
}
extension UUID : LosslessStringConvertible {
  public init?(_ description: String) {
    guard let value = UUID(uuidString: description) else {
      return nil
    }
    
    self = value
  }
}
final class WorkoutController {
  static let jsonEncoder = JSONEncoder()
//  let db: Database
//  
//  init(db: Database) {
//    self.db = db
//  }
  
  func create(req: Request) throws -> EventLoopFuture<WorkoutResponse> {
    let id = WebSocketService.shared.prepare()
    let bytes = ByteCollection(uuid: id)
    let data = Data(bytes)
    let workoutId = Base32CrockfordEncoding.encoding.encode(data: data)
    let response = WorkoutResponse(id: workoutId)
    return req.eventLoop.future(response)
  }
  
  func put(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
//    let workout = Workout.find(req.parameters.get("workoutID"), on: db).unwrap(or: Abort(HTTPResponseStatus.notFound))
//    let data = try req.content.decode(WorkoutData.self)
//
//    return workout.and(value: data).flatMap { (arg)  in
//      let (workout, data) = arg
//      var didChange = false
//      if let heartRate = data.heartRate {
//        workout.heartRate = heartRate
//        didChange = true
//      }
//      if didChange {
//        return workout.update(on: self.db).transform(to: HTTPStatus.accepted)
//      } else {
//        return self.db.eventLoop.future(HTTPStatus.noContent)
//      }
//    }
    
    let workoutData = try req.content.decode(WorkoutData.self)
    guard let id = req.parameters.get("workoutID") else {
      return req.eventLoop.future(error: Abort(.internalServerError))
    }
    
    
    let idData = try Base32CrockfordEncoding.encoding.decode(base32Encoded: id)
    let uuid = UUID(data: idData)
    
    
    guard let webSocket = WebSocketService.shared.get(webSocketWithId: uuid) else {
      return req.eventLoop.future(error: Abort(HTTPResponseStatus.notFound))
    }
    
    guard workoutData.heartRate != nil else {
      return req.eventLoop.future(HTTPStatus.noContent)
    }
    
    let data : Data
    do {
      data = try WorkoutController.jsonEncoder.encode(workoutData)
    } catch let error {
      return req.eventLoop.future(error: error)
    }
    
    guard let text = String(data: data, encoding: .utf8) else {
      return req.eventLoop.future(error: Abort(.internalServerError))
    }
    
    webSocket.send(text, mask: false)
    
    return req.eventLoop.future(.accepted)

  }
  
  func webSocket(_ req: Request, _ wss: WebSocket) {
    guard let id = req.parameters.get("workoutID") else {
      return
    }
    
    guard let idData = try? Base32CrockfordEncoding.encoding.decode(base32Encoded: id) else {
      return
    }
    
    let uuid = UUID(data: idData)
    
    WebSocketService.shared.save(wss, withID: uuid)
  }
  //
  //  func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
  //    return Todo.find(req.parameters.get("todoID"), on: self.db)
  //      .unwrap(or: Abort(.notFound))
  //      .flatMap { $0.delete(on: self.db) }
  //      .transform(to: .ok)
  //  }
}
