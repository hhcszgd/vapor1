//
//  Book.swift
//  App
//
//  Created by WY on 2019/7/30.
//

import Foundation
import Vapor
import FluentMySQL

final class Book: MySQLModel {
    /// The unique identifier for this `Todo`.
    var id: Int?
    
    /// A title describing what this `Todo` entails.
    var title: String
    
    /// Creates a new `Todo`.
    init(id: Int? = nil, title: String) {
        self.id = id
        self.title = title
    }
}

/// Allows `Todo` to be used as a dynamic migration.
extension Book: MySQLMigration {
    typealias Database = MySQLDatabase
    static func prepare(on conn: Database.Connection) -> Future<Void> {
        //创建表
        return Database.create(Book.self, on: conn) { builder in
            //方法1
//            builder.field(for: \.id, isIdentifier: true)
//            builder.field(for: \.title)
            //方法2
            try addProperties(to: builder)
        }
    }
    static func revert(on conn: Database.Connection) -> Future<Void> {
        return Database.delete(Book.self , on: conn)
    }
}

/// Allows `Todo` to be encoded to and decoded from HTTP messages.
extension Book: Content { }

/// Allows `Todo` to be used as a dynamic parameter in route definitions.
extension Book: Parameter { }
