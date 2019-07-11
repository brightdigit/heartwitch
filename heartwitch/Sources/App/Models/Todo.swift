import FluentSQLite
import Vapor

///// A single entry of a Todo list.
final class Workout: SQLiteUUIDModel {
    /// The unique identifier for this `Todo`.
    var id: UUID?

    /// A title describing what this `Todo` entails.
    var heartRate: Double?

    /// Creates a new `Todo`.
    init(id: UUID? = nil) {
        self.id = id
    }
  
  func willUpdate(on conn: SQLiteConnection) throws -> EventLoopFuture<Workout> {
    if let id = self.id, var heartRate = self.heartRate, let ws = websockets[id] {
      
      
      ws.send(heartRate.description)
    }
    return conn.future(self)
    
  }
}

/// Allows `Todo` to be used as a dynamic migration.
extension Workout: Migration { }

/// Allows `Todo` to be encoded to and decoded from HTTP messages.
extension Workout: Content { }

/// Allows `Todo` to be used as a dynamic parameter in route definitions.
extension Workout: Parameter { }
