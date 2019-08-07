//
//  BookController.swift
//  App
//
//  Created by WY on 2019/7/31.
//
import Vapor
import FluentMySQL

import NIO
class BookController{
//{ (<#Request#>, <#RequestDecodable#>) -> ResponseEncodable in
//    <#code#>
//    }
    func getBooks(_ req:Request) ->Future<Response> {
        let bookID = try? req.parameters.next(Int.self)
        print(bookID)
        if let bID = bookID{
            let bb = Book.find(bID, on: req)
            let c = bb.map { (b) -> (Book) in
                if b != nil {
                    return b!
                }else{
                    return Book(title: "mei zhao dao ")
                }
            }
            return c.encode(status: HTTPStatus.ok, for: req )
        }else{
            let books = Book.query(on: req).all().encode(status: HTTPStatus.ok, for: req)
            return books
            
        }
//        return "sss"
    }
    func getBook(_ req:Request) ->Future<Response> {
        
//        guard let bookID = try? req.parameters.next(Int.self) else{
//           Future.mapto
//            return  HTTPResponse(status: HTTPResponseStatus.badRequest).encode(for: req)
//
//        }
//        flatMap(<#T##futureA: EventLoopFuture<A>##EventLoopFuture<A>#>, <#T##futureB: EventLoopFuture<B>##EventLoopFuture<B>#>, <#T##callback: (A, B) throws -> EventLoopFuture<Result>##(A, B) throws -> EventLoopFuture<Result>#>)
        let theBook = Book.query(on: req).filter(\Book.id, MySQLBinaryOperator.equal, 1).first().unwrap(or: Abort(HTTPResponseStatus.badRequest))
        return theBook.encode(status: HTTPStatus.ok, for: req)
//        let bookID = try? req.parameters.next(Int.self)
//        print(bookID)
//            let bb = Book.find(bookID!, on: req)
//            let c = bb.map { (b) -> (Book) in
//                if b != nil {
//                    return b!
//                }else{
//                    return Book(title: "mei zhao dao ")
//                }
//            }
//            return c.encode(status: HTTPStatus.ok, for: req )
    }
    func saveBook( _  req:Request,_ b :Book)  -> String {
        return "ss"
    }
    func post(_ req:Request) -> String {
        return "sss"
    }
    func postbbbb(_ req:Request) -> String {
        let a : String? = "dd"
        let b = a.flatMap { (ss) -> Int? in
            if let i = Int(ss){
                return i
            }else {return nil  }
        }
        let g = try? req.content.decode(String.self).map(to: Int.self){ (ss)  in
            return 5
        }
        return "sss"
    }
}
