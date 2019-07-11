import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "It works" example
    router.get { req in
        return "It works!"
    }
    
//    // Basic "Hello, world!" example
//    router.post("workouts") { req in
//      let workout = Workout()
//      return workout.save(on: req)
//    }

    // Example of configuring a controller
    let todoController = WorkoutController()
//    router.get("todos", use: todoController.index)
    router.post("workouts", use: todoController.create)
//    router.delete("todos", Todo.parameter, use: todoController.delete)
}
