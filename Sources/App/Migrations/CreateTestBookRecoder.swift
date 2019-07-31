//
//  CreateTestBookRecoder.swift
//  App
//
//  Created by WY on 2019/7/31.
//
import Fluent
import FluentMySQL
import Foundation
struct CreateBookRecoder : Migration {
    typealias Database = MySQLDatabase
    static func prepare(on conn: Database.Connection) -> Future<Void> {
        var createdBoods = [Future<Book>]()
        for i  in 1...3 {
            let book = Book(id: i , title: "bood \(i)").create(on: conn)
            createdBoods.append(book)
        }
        //创建记录
        return createdBoods.flatten(on: conn).transform(to: Void())
    }
    static func revert(on conn: Database.Connection) -> Future<Void> {
        //清空book表,(包含id)
        return conn.query("truncate table `Book`")
            .transform(to: Void())
    }
}
