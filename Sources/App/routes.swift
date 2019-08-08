import Vapor
import Console
//import Authentication
/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "It works" example
    router.get { req in

        return "It works!"
    }
    
//    Creates a sub Router wrapped in the supplied middleware function.
    let group = router.grouped { req, next in
        // this closure will be called with each request
        //Middleware is placed between the server and your router. It is capable of mutating both incoming requests and outgoing responses.
        print(req.http.headers["Host"])
        print(req)
//        req.ma
//        next.makeResponder
        // use next responder in chain to respond
        return try next.respond(to: req)
    }
    //get : http://localhost:8080/testGroupedAndMiddleware
    group.get("testGroupedAndMiddleware") {req  in
        return "xxxx"
    }
//    router.grouped { (request, responder) -> EventLoopFuture<Response> in
//
//        return try responder.respond(to: request)
//    }
    let users = router.grouped("user")
    // Adding "user/auth/" route to router.
    users.get("auth") { req   in return "ok"}
    // adding "user/profile/" route to router
    users.get("profile") { req  in return "ok"}
    
    
    router.group("user") { users in
        // Adding "user/auth/" route to router.
        users.get("auth") { req  in
            return "ok"}
        // adding "user/profile/" route to router
        users.get("profile"){ req   in return "ok"}
    }
    //    get :  /v1/homePage
    router.group("v1") { (group) in
        group.get("homePage", use: { (req) -> String in
            return "ok"
        })
    }
    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "Hello, world!"
    }
    let studyMoudle = StudyController()
    router.get("console-input", use: studyMoudle.testCrypto)
    //http://localhost:8080/users/222
    router.get("users", Int.parameter, use : studyMoudle.handleGetRequest)
    router.post( DDRequestModel.self, at:"hhhh",use :studyMoudle.handlePostRequest)
    router.get("getUrlsOfJD", use: studyMoudle.getUrlsOfJD)
    router.get("testCustomResponse", use: studyMoudle.testCustomResponse)
    router.get("testRouterParameters",Int.parameter, use: studyMoudle.testRouterParameters)
    
    
    
    //不带参数的post
    router.post("ssss") { (request) -> String in
        return  "returnnnnn"
    }
    //带json对象类型参数的post
    //final url  =  "http://localhost:8080/testpost";
    //await Dio().post(url , data: {"title":"金瓶子","id":2});
    router.post([String:String].self, at: "testpost") { (request, string) -> String in
        
        print("print body :::: \(2)")
        print(string)
        return string["ss"]! + "   haha"
    }
    //带自定义对象类型参数的post
    //final url  =  "http://localhost:8080/testPostBook";
    //await Dio().post(url , data: {"title":"金瓶子","id":2});
    router.post(Book.self, at: "testPostBook") { (request, b ) -> String in
        print(b.title)
        return "你输入的是 : "  + b.title
    }
    //改进版带自定义对象类型参数的post
    //final url  =  "http://localhost:8080/saveBook";
    //await Dio().post(url , data: {"title":"金瓶子","id":2});
    let bc = BookController()
    router.post(Book.self, at: "saveBook", use: bc.saveBook )
    router.get("books" , Int.parameter, use: bc.getBooks)
    router.get("book" , Int.parameter, use: bc.getBook)

    router.get("savebook") { (req) -> String in
        //        BookController.test(req)
        Book(title: "信ggg息").save(on: req)
        return "kkkk"
    }
    
    
    
    testRequestServer(router:router)
    
    testConvertCustomObject(router: router)
    try testConvertCustomObject1(router: router)
    // Example of configuring a controller
    let todoController = TodoController()
    router.get("todos", use: todoController.index)
    router.post("todos", use: todoController.create)
    router.delete("todos", Todo.parameter, use: todoController.delete)
}

private func testSaveBook(router:Router){
//    router.get("savebook") { (req) -> String in
////        BookController.test(req)
//        Book(title: "信息").save(on: req)
//        return "kkkk"
//    }
}

private func testRequestServer(router:Router){
    router.get("books") {
        req -> Future<Response> in
        
        return Book.query(on: req)
            .all()
            .map(to: UserContext.self) {
                books  -> UserContext in
                return UserContext(
                    userName: "JohnLock",
                    books: books)
            }
            .encode(status: .created, for: req)
    }
}





private func testConvertCustomObject(router:Router){
    // 把客户端提交过来的数据直接转换成自定义对象(异步等待返回给客户端)
    router.get("my-object",MyObject.parameter) { req -> MyObject in
    //把客户端提交过来的数据直接转换成自定义对象,需要遵守Parameter协议并实现协议方法方法
        let r = try req.parameters.next(MyObject.self)
        return r//直接返回对象json (需遵守Content协议) , 如{"id":99999,"desc":"this is correct id :99999"}
    }
}
struct MyObject : Content{//遵守Content方法,不需要要实现方法
    var id : Int
    var desc = ""
    init(idStr : String) {
        if let idInt = Int(idStr){
            id = idInt
            self.desc = "this is correct id :\(id)"
        }else{
            id = 0
            self.desc = "this is incorrect id :\(idStr)"
        }
    }
}
extension MyObject : Parameter {//遵守Parameter协议,需要实现方法
    static func resolveParameter(_ parameter: String, on container: Container) throws -> MyObject{
        return MyObject(idStr: parameter)
    }
}







private func testConvertCustomObject1(router:Router) throws{
    // 把客户端提交过来的数据直接转换成自定义对象
    router.get("my-object1",MyObject1.parameter) { req -> Future<MyObject1> in
        //把客户端提交过来的数据直接转换成自定义对象,需要遵守Parameter协议并实现协议方法方法
        let r = try req.parameters.next(MyObject1.self)
        
        // 如果Future里的对象还需要一个耗时操作,那就会生成一个
    //Future<Future<MyObject1>>前天Future的对象,想避免这种情况
        //就用flatMap来取代map方法来解决
        let returnObj =  r.map(to : MyObject1.self){ myObject1 in
            guard let o = myObject1 else {
                throw Abort(.badRequest)
            }
            return o
            
        }
        return returnObj
    }
}
struct MyObject1 : Content{//遵守Content方法,不需要要实现方法
    var id : Int
    var desc = ""
    init(idStr : String) {
        if let idInt = Int(idStr){
            id = idInt
            self.desc = "this is correct id :\(id)"
        }else{
            id = 0
            self.desc = "this is incorrect id :\(idStr)"
        }
    }
}
extension MyObject1 : Parameter {//遵守Parameter协议,需要实现方法
    static func resolveParameter(_ parameter: String, on container: Container) throws -> Future<MyObject1?>{
        //正常场景应该是做一些耗时操作(如读取数据库)之后,再返回相应的对象,此时只是直接创建对象并返回
        return Future.map(on: container, {
             MyObject1(idStr: parameter)
        })
    }
}

