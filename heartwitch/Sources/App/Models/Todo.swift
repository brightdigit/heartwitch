import FluentSQLite
import Vapor

let jsonEncoder = JSONEncoder()


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
  
  static let createdAtKey: TimestampKey? = \.createdAt
  static let updatedAtKey: TimestampKey? = \.updatedAt
  
  var createdAt: Date?
  var updatedAt: Date?
  
  func willUpdate(on conn: SQLiteConnection) throws -> EventLoopFuture<Workout> {
    guard let wkData = self.data() else {
      return conn.future(self)
    }
    if let id = self.id, var heartRate = self.heartRate, let data = try? jsonEncoder.encode(wkData), let ws = websockets[id] {
      let text = String(bytes: data, encoding: .utf8)!
      ws.send(text)
      //ws.send(heartRate.description)
    }
    return conn.future(self)
    
  }
  
  func data () -> WorkoutData? {
    return WorkoutData(heartRate: self.heartRate)
  }
}

/// Allows `Todo` to be used as a dynamic migration.
extension Workout: Migration { }

/// Allows `Todo` to be encoded to and decoded from HTTP messages.
extension Workout: Content { }

/// Allows `Todo` to be used as a dynamic parameter in route definitions.
extension Workout: Parameter { }
