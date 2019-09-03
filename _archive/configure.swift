import FluentSQLite
import Vapor
import WebSocket
import Foundation

var websockets = [UUID : WebSocket]()
let jsonDecoder = JSONDecoder()
/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    // Register providers first
  try services.register(FluentSQLiteProvider())

    // Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    // Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config

  
    middlewares.use(FileMiddleware(publicDirectory: Environment.get("PUBLIC_FOLDER")!)) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)

  // Create a new NIO websocket server
  let wss = NIOWebSocketServer.default()
  
  // Add WebSocket upgrade support to GET /echo
  wss.get("workouts", Workout.parameter, "run") { ws, req in
    // Add a new on text callback
    print("Watch Connected!")
    _ = try req.parameters.next(Workout.self).map{
      workout in
     
      ws.onBinary { (ws, data) in
print("Data Received!")
        if let workoutData = try? jsonDecoder.decode(WorkoutData.self, from: data) {
          print("Heart Rate \(workoutData.heartRate)")
          workout.heartRate = workoutData.heartRate
          

          _ = workout.save(on: req)
        }
      }
    }
  }
  
  wss.get("workouts", Workout.parameter, "listen") { ws, req in
    // Add a new on text callback
    
    try req.parameters.next(Workout.self).map({
      workout in
      let id = try workout.requireID()
      websockets[id] = ws
    })
  }
    // Configure a SQLite database
    let sqlite = try SQLiteDatabase(storage: .memory)

   //  Register the configured SQLite database to the database config.
    var databases = DatabasesConfig()
    databases.add(database: sqlite, as: .sqlite)
    services.register(databases)

    // Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: Workout.self, database: .sqlite)
    services.register(migrations)
  services.register(wss, as: WebSocketServer.self)
}
