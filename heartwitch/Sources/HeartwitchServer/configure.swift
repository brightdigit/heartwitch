import Fluent
import FluentSQLiteDriver
import Vapor
import NIO

class WebSocketService  {
  static let shared = WebSocketService()
  var webSockets = [UUID:WebSocket]()
  
  func save (_ webSocket: WebSocket, withID id: UUID)  {
    if let webSocket = self.webSockets[id] {
      webSocket.close(code: WebSocketErrorCode.goingAway)
    }
    self.webSockets[id] = webSocket
  }
  
  func get (webSocketWithId id: UUID) -> WebSocket? {
    return self.webSockets[id]
  }
}

/// Called before your application initializes.
func configure(_ s: inout Services) throws {
  /// Register providers first
  s.provider(FluentProvider())
  
  /// Register routes
  s.extend(Routes.self) { r, c in
    try routes(r, c)
  }
  
  /// Register middleware
  s.register(MiddlewareConfiguration.self) { c in
    // Create _empty_ middleware config
    var middlewares = MiddlewareConfiguration()
    
    // Serves files from `Public/` directory
      
    
    try middlewares.use(FileMiddleware(publicDirectory: "../../../../../Heartwitch/Public", fileio: c.make(FileIO.self) ))
    
    // Catches errors and converts to HTTP response
    try middlewares.use(c.make(ErrorMiddleware.self))
    
    return middlewares
  }
  
  s.extend(Databases.self) { dbs, c in
    try dbs.sqlite(configuration: c.make(), threadPool: c.make())
  }
  
  s.register(SQLiteConfiguration.self) { (c) in
    return .init(storage: .memory)
  }
  
  s.register(Database.self) { c in
    return try c.make(Databases.self).database(.sqlite)!
  }
  
  s.register(Migrations.self) { c in
    var migrations = Migrations()
    migrations.add(CreateWorkout(), to: .sqlite)
    return migrations
  }
}
