//
//  2019-07-30-CreateBookTable.swift
//  App
//
//  Created by WY on 2019/7/30.
//
import Fluent
import FluentMySQL
import Foundation
struct CreateBookTable : Migration {
    typealias Database = MySQLDatabase
    static func prepare(on conn: Database.Connection) -> Future<Void> {
        //创建表
        return Database.create(Book.self, on: conn) { builder in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.title)
        }
    }
    static func revert(on conn: Database.Connection) -> Future<Void> {
        return Database.delete(Book.self , on: conn)
    }
}
