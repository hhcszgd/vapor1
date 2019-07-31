//
//  UserContext.swift
//  App
//
//  Created by WY on 2019/7/31.
//


import Foundation
import Vapor
import FluentMySQL

struct UserContext : Codable , Content {
    /// The unique identifier for this `Todo`.
    
    /// A title describing what this `Todo` entails.
    var userName: String?
    var books : [Book]?
    /// Creates a new `Todo`.
    init(userName:String?,books:[Book]?) {
        self.userName = userName
        self.books = books
    }
}
