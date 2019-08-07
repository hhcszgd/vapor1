//
//  StudyModel.swift
//  App
//
//  Created by WY on 2019/8/5.
//

import Vapor
import FluentMySQL
/// A single entry of a Todo list.
//final class DDRequestModel: MySQLModel {
//    /// The unique identifier for this `Todo`.
//    var id: Int?
//
//    /// A title describing what this `Todo` entails.
//    var title: String
//
//    /// Creates a new `Todo`.
//    init(id: Int? = nil, title: String) {
//        self.id = id
//        self.title = title
//    }
//}
//
///// Allows `Todo` to be used as a dynamic migration.
//extension DDRequestModel: Migration { }
//
///// Allows `Todo` to be encoded to and decoded from HTTP messages.
//extension DDRequestModel: Content { }
//
///// Allows `Todo` to be used as a dynamic parameter in route definitions.
//extension DDRequestModel: Parameter { }



// fuck  , 必须加final , why
final class DDRequestModel : MySQLModel  {
    var id : Int?//主键必须加
    var title : String
    init(title:String , id : Int? = nil ) {
        self.title = title
        self.id = id
    }
}
extension DDRequestModel : Migration { }
extension DDRequestModel : Content{}
extension DDRequestModel : Parameter{}
