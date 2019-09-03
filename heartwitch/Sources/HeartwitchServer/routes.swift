import Fluent
import Vapor

func routes(_ r: Routes, _ c: Container) throws {
  

  let workoutController = try WorkoutController(db: c.make())
  //r.get("todos", use: todoController.index)
  r.post("workouts", use: workoutController.create)
  r.put("workouts", ":workoutID", use: workoutController.put)
  r.webSocket("workouts", ":workoutID", onUpgrade: workoutController.webSocket)
              
  // r.on(.DELETE, "todos", ":todoID", use: todoController.delete)
  
}
