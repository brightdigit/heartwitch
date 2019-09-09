//import Fluent
import Vapor

func routes(_ r: Routes, _ c: Container) throws {
  


  r.get { (request) throws -> EventLoopFuture<Response> in
     let fileio = try c.make(FileIO.self)
     let res = fileio.streamFile(at: "../../../../../Heartwitch/Public/index.html", for: request)
     return fileio.eventLoop.makeSucceededFuture(res)
  }

  let registrationController = try RegistrationController(db: c.make())
  
  r.post("registrations", use: registrationController.create)
  
  let workoutController = WorkoutController()

  //r.get("todos", use: todoController.index)
  r.post("workouts", use: workoutController.create)

 
  r.put("workouts", ":workoutID", use: workoutController.put)
  r.webSocket("workouts", ":workoutID", onUpgrade: workoutController.webSocket)
              
  // r.on(.DELETE, "todos", ":todoID", use: todoController.delete)
  
}
