import Vapor

/// Controls basic CRUD operations on `Todo`s.
final class WorkoutController {
  //    /// Returns a list of all `Todo`s.
  //    func index(_ req: Request) throws -> Future<[Todo]> {
  //        return Todo.query(on: req).all()
  //    }
  
  /// Saves a decoded `Todo` to the database.
  func create(_ req: Request) throws -> Future<Workout> {
    //        return try req.content.decode(Todo.self).flatMap { todo in
    //            return todo.save(on: req)
    //        }
    return Workout().save(on: req)
  }
  
  func put(_ req: Request) throws -> Future<HTTPStatus> {
    let workout = try req.parameters.next(Workout.self)
    let data = try req.content.decode(WorkoutData.self)
    return workout.and(data).flatMap { (arg)  in
      let (workout, data) = arg
      var didChange = false
      if let heartRate = data.heartRate {
        workout.heartRate = heartRate
        didChange = true
      }
      if didChange {
        return workout.update(on: req).transform(to: HTTPStatus.accepted)
      } else {
        return req.future(HTTPStatus.noContent)
      }
    }
  }
  //
  //    /// Deletes a parameterized `Todo`.
  //    func delete(_ req: Request) throws -> Future<HTTPStatus> {
  //        return try req.parameters.next(Todo.self).flatMap { todo in
  //            return todo.delete(on: req)
  //        }.transform(to: .ok)
  //    }
}
