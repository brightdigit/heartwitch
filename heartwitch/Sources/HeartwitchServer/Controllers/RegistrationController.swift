import OpenCrypto
import Vapor
import Fluent
import Base32Crockford

/// Creates new users and logs them in.
final class RegistrationController {
  let db: Database
  
  init(db: Database) {
    self.db = db
  }
  func create(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
    let registration = try req.content.decode(Registration.self)
    return registration.save(on: db).transform(to: .created)
//    let query = Registration.query(on: db).filter(\.$emailAddress == registration.emailAddress)
//    if let registration = query.first() {
//      return req.eventLoop.future(.found)
//    } else {
//      registration.save(on: db).
//    }
    
  }

}
  /// Logs a user in, returning a token for accessing protected endpoints.
//  func login(_ req: Request) throws -> Future<TokenResponse> {
//    // get user auth'd by basic auth middleware
//    let user = try req.requireAuthenticated(User.self)
//    // create new token for this user
//    let token = try UserToken.create(userID: user.requireID()).save(on: req)
//    let accessGroups = try user.accessGroups.query(on: req).all()
//    let job = try Job.query(on: req).sort(\.createdAt, .descending).filter(\.failureReason == nil).first()
//
//    // save and return token
//    return token.and(accessGroups).and(result: user).and(job).map {
//      try TokenResponse(token: $0.0.0.0, user: $0.0.1, accessGroups: $0.0.0.1, job: $0.1)
//    }
//  }
//
//  func get(_ req: Request) throws -> Future<UserResponse> {
//    let userSelf = try? req.requireAuthenticated(User.self)
//    let userName = try req.parameters.next(String.self)
//
//    let user = User.query(on: req).filter(\.name == userName).first().map { (user) -> (User) in
//      guard let user = user else {
//        throw Abort(.notFound)
//      }
//      return user
//    }
//
//    let gamesFuture = user.flatMap { (user)  in
//      return try user.games.pivots(on: req).join(\Game.id, to: \UserGame.gameId).filter(\.quantity > 0).sort(\.updatedAt, .descending).alsoDecode(Game.self).range(lower: 0, upper: 10).all().flatMap{
//        try $0.map
//        { (arg) -> EventLoopFuture<GameResponse> in
//          let (userGame, game) = arg
//          return try game.physical.query(on: req).all().map({ (types) -> (GameResponse) in
//            return try GameResponse(game: game, physicalDetail: types.compactMap{ GamePhysicalTypeDetail(rawValue: try $0.requireID())}, quantity: userGame.quantity)})
//          //return try GameResponse(game: game, quanity: userGame.quantity)
//          }.flatten(on: req)
//      }
//    }
//
//    let userFollows : EventLoopFuture<[(UserRelationship, User)]> = user.flatMap{ (user)  in
//      let query = try user.relationships.pivots(on: req).filter(\.relationshipId == "follows")
//      return query.join(\User.id, to: \UserRelationship.relationshipUserId).alsoDecode(User.self).all()
//    }
//
//
//    let selfFollows : EventLoopFuture<[UUID]?> = try {
//      guard let userSelf = $0 else {
//        return req.eventLoop.newSucceededFuture(result: nil)
//      }
//      return try UserRelationship.query(on: req).filter(\.sourceUserId == userSelf.requireID()).filter(\.relationshipId == RelationshipType.follows.rawValue).all().map{ try $0.map{ $0.relationshipUserId }}
//    }(userSelf)
//
//
//    let followsFuture =  userFollows.and(selfFollows).map { (args) -> ([RelationshipUserResponse]?) in
//      let (users, foundIds) = args
//      guard let ids = foundIds else {
//        return nil
//      }
//      return users.map({ (followUser) -> RelationshipUserResponse in
//        let (relationshipUser, user) = followUser
//        let relationship = ids.contains(relationshipUser.relationshipUserId) ? RelationshipType.follows : nil
//        return RelationshipUserResponse(id: relationshipUser.relationshipUserId, handle: user.name, relationship: relationship)
//      })
//    }
//
//    let doesFollow = user.and(selfFollows).map({ (arg) -> (Bool?) in
//      return arg.1?.contains(try arg.0.requireID())
//    })
//
//    return user.and(gamesFuture).and(followsFuture).and(doesFollow).map { (args) -> (UserResponse) in
//      let (userAndGamesFollows, doesFollow) = args
//      let (userAndGames, follows) = userAndGamesFollows
//      let (user, games) = userAndGames
//      let selfRelationships : [RelationshipType]?
//      if let actualDoesFollow = doesFollow {
//        selfRelationships = actualDoesFollow ? [RelationshipType.follows] : [RelationshipType]()
//      } else {
//        selfRelationships = nil
//      }
//      return try UserResponse(id: user.requireID(), handle: user.name, friendCode: user.friendCode, relationships: follows, games: games, selfRelationshipTypes: selfRelationships)
//    }
//  }
//
//  func update(_ req: Request) throws -> Future<HTTPStatus> {
//
//    let user = try req.requireAuthenticated(User.self)
//    let updateRequest = try req.content.decode(UpdateUserRequest.self)
//
//    return updateRequest.flatMap{
//      user.friendCode = $0.friendCode ?? user.friendCode
//      return user.save(on: req).transform(to: HTTPStatus.ok)
//    }
//  }
//
//  /// Creates a new user.
//  func create(_ req: Request) throws -> Future<UserResponse> {
//    // decode request content
//
//    return try req.content.decode(CreateUserRequest.self).flatMap({ (userRequest) -> EventLoopFuture<UserResponse> in
//      Registration.query(on: req).filter(\.email == userRequest.email).first().flatMap({ (foundRegistration) -> EventLoopFuture<UserResponse> in
//        guard let registration = foundRegistration else {
//          throw Abort(.notFound)
//        }
//        guard registration.confirmationCode == userRequest.confirmationCode else {
//          throw Abort(.conflict)
//        }
//        #warning ("Add Check For Old Confirmation Code")
//        guard userRequest.password == userRequest.verifyPassword else {
//          throw Abort(.badRequest, reason: "Password and verification must match.")
//        }
//        let hash = try BCrypt.hash(userRequest.password)
//              // save new user
//        return try User(name: userRequest.name, passwordHash: hash, registration: registration).save(on: req).map{
//          return try UserResponse(id: $0.requireID(), handle: $0.name)
//        }
//      })
//    })
//  }
//
//  func relationshipCreate(_ req: Request) throws -> Future<HTTPStatus> {
//    let relationship = try req.parameters.next(Relationship.self)
//    let toUserHandle = try req.parameters.next(String.self)
//    let fromUser = try req.requireAuthenticated(User.self)
//    let toUserPossible = User.query(on: req).filter(\.name == toUserHandle).first()
//    return relationship.and(toUserPossible).flatMap { (args)  -> EventLoopFuture<UserRelationship> in
//      let (relationship, toUserFound) = args
//      guard let toUser = toUserFound else {
//        throw Abort(.notFound)
//      }
//      return try UserRelationship(relationship: relationship, fromUser: fromUser, toUser: toUser).save(on: req)
//    }.transform(to: HTTPStatus.created)
//  }
//
//  func relationshipDelete(_ req: Request) throws -> Future<HTTPStatus> {
//    let relationship = try req.parameters.next(Relationship.self)
//    let toUserHandle = try req.parameters.next(String.self)
//    let fromUser = try req.requireAuthenticated(User.self)
//    let toUserPossible = User.query(on: req).filter(\.name == toUserHandle).first()
//    return relationship.and(toUserPossible).flatMap({ (args) -> EventLoopFuture<[UserRelationship]> in
//      let (relationship, toUserFound) = args
//      guard let toUser = toUserFound else {
//        throw Abort(.notFound)
//      }
//      return try UserRelationship.query(on: req).filter(\.sourceUserId == fromUser.requireID()).filter(\.relationshipUserId == toUser.requireID()).filter(\.relationshipId == relationship.requireID()).all()
//    }).flatMap({ (userRelationships) -> EventLoopFuture<Void> in
//      guard userRelationships.count > 0 else {
//        throw Abort(.notFound)
//      }
//      return userRelationships.map{
//        $0.delete(on: req)
//      }.flatten(on: req)
//    }).transform(to: .ok)
//  }


// MARK: Content

/// Data required to create a user.
//struct CreateUserRequest: Content {
//
//  /// User's email address.
//  var email: String
//
//  var confirmationCode: String
//
//  /// User's desired password.
//  var password: String
//
//  var verifyPassword : String
//
//}


///// Public representation of user data.
//struct UserResponse: Content {
//  let id : String
//  let handle : String
//
//  var games : [GameResponse]?
//
//  var relationships : [RelationshipUserResponse]?
//
//  var friendCode : String?
//
//  var selfRelationshipTypes : [RelationshipType]?
//
//  public init (id: UUID, handle: String, friendCode: String? = nil, relationships : [RelationshipUserResponse]? = nil, games: [GameResponse]? = nil, selfRelationshipTypes: [RelationshipType]? = nil) {
//    let userIdData = Data(uuid: id)
//    self.id = Base32CrockfordEncoding.encoding.encode(data: userIdData)
//    self.handle = handle
//    self.friendCode = friendCode
//    self.selfRelationshipTypes = selfRelationshipTypes
//    self.games = games
//    self.relationships = relationships
//  }
//}

//struct RelationshipUserResponse : Content {
//  let id : String
//  let handle : String
//  var relationship : RelationshipType?
//  public init (id: UUID, handle: String, relationship: RelationshipType?) {
//    let userIdData = Data(uuid: id)
//    self.id = Base32CrockfordEncoding.encoding.encode(data: userIdData)
//    self.handle = handle
//    self.relationship = relationship
//  }
//}

//
//struct TokenResponse : Content {
//  let token : String
//  let expiresAt: Date?
//  let user : UserResponse
////  let accessGroups : [String]
////  let jobStatus : Job?
//
//  init (token : UserToken, user: User) throws {
////    let userIdData = try Data(uuid: user.requireID())
////    let id = Base32CrockfordEncoding.encoding.encode(data: userIdData)
//   // self.jobStatus = accessGroups.compactMap{$0.id}.contains("admin") ? job : nil
//    self.token = token.token
//    self.expiresAt = token.expiresAt
//   // self.accessGroups = accessGroups.compactMap{ $0.id }
//    self.user = try UserResponse(id: user.requireID(), handle: user.name)
//  }
//}
//
//extension Data {
//  init (uuid: UUID) {
//    self.init(bytes: ByteCollection(uuid: uuid))
//  }
//}
