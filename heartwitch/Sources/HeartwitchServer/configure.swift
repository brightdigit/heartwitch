import Fluent
import Vapor
import NIO
import FluentPostgresDriver

class WebSocketService  {
  static let shared = WebSocketService()
  var webSockets = [UUID:WebSocket]()
  var readyIds = Set<UUID>()
  
  func prepare () -> UUID {
    let id = UUID()
    readyIds.formUnion([id])
    return id 
  }
  
  func save (_ webSocket: WebSocket, withID id: UUID) {
    //    if let webSocket = self.webSockets[id] {
    //      webSocket.close(code: WebSocketErrorCode.goingAway)
    //    }
    guard let webSocketId = readyIds.remove(id) else {
      return
    }
    webSocket.onCloseCode { (code) in
      print(webSocketId, code, webSocket)
      self.webSockets.removeValue(forKey: webSocketId)
    }
    self.webSockets[webSocketId] = webSocket
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
    //try dbs.sqlite(configuration: c.make(), threadPool: c.make())
    try dbs.postgres(config: c.make())
  }
  
  //   s.register(SQLiteConfiguration.self) { (c) in
  //     return .init(storage: .connection(.file(path: "db.sqlite")))
  //   }
  s.register(PostgresConfiguration.self) { (c) in
    return .init(hostname: "localhost", username: "heartwitch", password: "heartwitch")
  }
  
  s.register(Database.self) { c in
    return try c.make(Databases.self).database(.psql)!
  }
  
  s.register(Migrations.self) { c in
    var migrations = Migrations()
    migrations.add(CreateRegistration(), to: .psql)
    return migrations
  }
}
