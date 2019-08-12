//
//  StudyController.swift
//  App
//
//  Created by WY on 2019/8/5.
//

import Vapor
class StudyController {
    func ttsts(_ req : Response) {
        let name: Future<String?> = try req.content["user", "name"]
        try? req.content.decode(json: String.self, using: JSONDecoder.custom())
    }
    func handlePostRequest(_ req : Request ,_ para: DDRequestModel) -> DDRequestModel {
        return para
    }
   
    func handleGetRequest(_ req : Request) -> String {
//        req.fileio()
//        Request.fi
        let id = try?   req.parameters.next(Int.self)
        return "requested id #\(id ?? 0)"
    }
    func testRouterParameters(_ req : Request)  throws ->  EventLoopFuture<Response>{
        print( req.query)
        let post = try req.parameters.next(Book.self)
        post.map { (b ) in
            print(b.title)
        }
//        let ids = req.parameters.rawValues(for: Int.self)
//        print(ids) // [String]
        let bk = Book(id: 333, title: "sss")
       return try bk.encode(for: req)
    }
    func testCustomResponse(_ req : Request)  throws ->  EventLoopFuture<Response>{
//        let response = req.response(http: HTTPResponse.init(status: HTTPResponseStatus.notFound))
        
        let responseBody = ["message":"some thing wrong","status":"200","data":"this is data"]
        let bk = Book(id: 333, title: "sss")
        //自定义body的方式1(好简单)
//        return try responseBody.encode(for: req)
        //自定义body的方式2
        let jsonData = try? JSONEncoder().encode(bk)
        let json = String(data: jsonData ?? Data(), encoding: String.Encoding.utf8)
        let response = req.response(http: HTTPResponse.init(status: HTTPResponseStatus.notFound ,body:HTTPBody(string: json ?? "nono")) )
        let futureResponse = req.eventLoop.newSucceededFuture(result: response)
        return futureResponse
        //自定义body方式3
        
        
//         Abort(.badRequest, reason: "Could not get data from external API.")
    }
    func testCrypto( _  req:Request)  -> String {
        let terminal = Terminal()
        print(terminal is Console) // true
        terminal.print("Hello")
        let console = try! req.make(Console.self)
        console.output("Hello, " + "world".consoleText(color: .blue))
        print("write something please : ")
        let input = console.input()
        console.print("You wrote: \(input)  , just now ")
        
        /// Outputs the prompt then requests input.
        let name = console.ask("What is your name?")
        console.print("You said: \(name)")
        
        /// Prompts the user for yes / no input.
        if console.confirm("Are you sure?") {
            // they are surel
            print("yeeees")
        } else {
            // don't do it!
            print("nooooooo")
        }
        
        return "success"
    }
}

extension StudyController{
    func getUrlsOfJD1(_ req : Request)  throws   -> EventLoopFuture<Response> {
        let url = "http://www.jd.com"
        let result = try? req.client().get(url)
        
        let result2 = result?.map({ (rep) -> (Response) in
            print("..................85...................")
            let bodyyy = rep.http.body
            if let data = bodyyy.data{
                var bodyString  = String(data: data, encoding: String.Encoding.utf8) ?? "空空空"
                let pattern = "(https://yp.jd.com/\\w+.html)"
                let goodsPattern = "(https://item.jd.com/\\w+.html)"
                let reg = try? NSRegularExpression(pattern: "(href=\"//[\\w.&;\\#]+\">)", options: [NSRegularExpression.Options.allowCommentsAndWhitespace,NSRegularExpression.Options.caseInsensitive])
                //                bodyString = "https://yp.jd.com/737684bb8e2dce70341.html"
                let arr = reg?.matches(in: bodyString, options: NSRegularExpression.MatchingOptions.init(rawValue: 0), range: NSMakeRange(0, bodyString.count))
                var urlss = [String]()
                for i in arr ?? []{
                    //                    print(i.range)
                    var uurl = NSString(string: bodyString).substring(with:
                        i.range)
                    uurl = uurl.replacingOccurrences(of: "&#47;", with: "/") ;
                    uurl = uurl.replacingOccurrences(of: "&#47", with: "/") ;
                    uurl = uurl.replacingOccurrences(of: "href=\"", with: "https:")
                    uurl = uurl.replacingOccurrences(of: ";\">", with: "")
                    uurl = uurl.replacingOccurrences(of: "\">", with: "")
                    urlss.append(uurl)
                }
                let urlssData = (try? JSONEncoder().encode(urlss)) ?? Data()
                return Response(http: HTTPResponse(status: HTTPResponseStatus.ok, body:  HTTPBody(data: urlssData)), using: req)
            }
            print("...................115..................")
            return Response(http: HTTPResponse(status: HTTPResponseStatus.ok, body:  HTTPBody(string: "errorrrr ")), using: req)
        })
            .flatMap({ (rep) -> EventLoopFuture<Response> in
                
//                return Response(http: HTTPResponse(status: HTTPResponseStatus.ok, body:  HTTPBody(string:"xxxxii")), using: req)/////
                var targetUrls = Set<String>()
                let dd = rep.http.body.data ?? Data()
                var resp = Response(using: req)
                let urls = ( try? JSONDecoder().decode([String].self, from: dd) ) ?? []

                ////
                var futureResponse :[Future<Response>] = []
                for url in urls {
                    //wait 不能再事件循环里调用,要再子线程里调用,比如.globall里
                    let result = try? req.client().get(url)
                    let p = result?.map({ (rep) -> Response in
                        print(".....................................")
                        let bodyyy = rep.http.body
                        if let data = bodyyy.data{
                            var bodyString  = String(data: data, encoding: String.Encoding.utf8) ?? ""
                            if bodyString.count <= 0 {
                                let cfEnc = CFStringEncodings.GB_18030_2000
                                let enc = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(cfEnc.rawValue))
                                //                    let str = String(data: data!, encoding: String.Encoding(rawValue: enc))
                                bodyString  = String(data: data, encoding: String.Encoding.init(rawValue: enc)) ?? ""
                            }
                            //                (https://\\w+.jd.com/[\\w/]+.html)|
                            let goodsPattern = "(\\w+.jd.com[\\w/\\\\]*.html)|(https://\\w+.jd.com/[\\w/]*.html)"//有的链接被转义了,\\\\是匹配转义字符
                            //如 : item.jd.com\/22283934451.html
                            let reg = try? NSRegularExpression(pattern:goodsPattern, options: [NSRegularExpression.Options.allowCommentsAndWhitespace,NSRegularExpression.Options.caseInsensitive])
                            let arr = reg?.matches(in: bodyString, options: NSRegularExpression.MatchingOptions.init(rawValue: 0), range: NSMakeRange(0, bodyString.count))
                            for i in arr ?? []{
                                var uurl = NSString(string: bodyString).substring(with:
                                    i.range)
                                uurl = uurl.replacingOccurrences(of: "\\", with: "")
                                if !(uurl.hasPrefix("http")){
                                    uurl = "https://" + uurl
                                }
                                targetUrls.insert(uurl)
                            }
                        }
                        
                        let urlssData = (try? JSONEncoder().encode(Array(targetUrls))) ?? Data()
                        resp = Response(http: HTTPResponse(status: HTTPResponseStatus.ok, body:  HTTPBody(data: urlssData)), using: req)
                        return resp
                    })
                    futureResponse.append(p!)
//                    return p!
                }
                let ax = futureResponse.flatten(on: req)
                let bx = ax.map({ (respArr) -> (Response) in
                    let ae = respArr.map({ (rep) -> String in
                        return rep.http.body.description
                    }).description
                    return Response(http: HTTPResponse(status: HTTPResponseStatus.ok, body:  HTTPBody(string: ae)), using: req)
                    
//                    return
                })
                return bx
                //////
                })

//            .flatMap({ (rep) -> EventLoopFuture<Response> in
//                return try "xxxxx2".encode(for: req)
//            })
//            .map({ (rep) -> Response in
//
//                return Response(http: HTTPResponse(status: HTTPResponseStatus.ok, body:  HTTPBody(string:"xxxxii")), using: req)/////
//            var targetUrls = Set<String>()
//            let dd = rep.http.body.data ?? Data()
//            var resp = Response(using: req)
//            let urls = ( try? JSONDecoder().decode([String].self, from: dd) ) ?? []
//                for url in urls {
//                    //wait 不能再事件循环里调用,要再子线程里调用,比如.globall里
//                    let result = try? req.client().get(url)
//                    let p = result?.map({ (rep) -> Response in
//                        print(".....................................")
//
//                        let bodyyy = rep.http.body
//                        if let data = bodyyy.data{
//                            var bodyString  = String(data: data, encoding: String.Encoding.utf8) ?? ""
//                            if bodyString.count <= 0 {
//                                let cfEnc = CFStringEncodings.GB_18030_2000
//                                let enc = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(cfEnc.rawValue))
//                                //                    let str = String(data: data!, encoding: String.Encoding(rawValue: enc))
//                                bodyString  = String(data: data, encoding: String.Encoding.init(rawValue: enc)) ?? ""
//                            }
//                            //                (https://\\w+.jd.com/[\\w/]+.html)|
//                            let goodsPattern = "(\\w+.jd.com[\\w/\\\\]*.html)|(https://\\w+.jd.com/[\\w/]*.html)"//有的链接被转义了,\\\\是匹配转义字符
//                            //如 : item.jd.com\/22283934451.html
//                            let reg = try? NSRegularExpression(pattern:goodsPattern, options: [NSRegularExpression.Options.allowCommentsAndWhitespace,NSRegularExpression.Options.caseInsensitive])
//                            let arr = reg?.matches(in: bodyString, options: NSRegularExpression.MatchingOptions.init(rawValue: 0), range: NSMakeRange(0, bodyString.count))
//                            for i in arr ?? []{
//                                var uurl = NSString(string: bodyString).substring(with:
//                                    i.range)
//                                uurl = uurl.replacingOccurrences(of: "\\", with: "")
//                                if !(uurl.hasPrefix("http")){
//                                    uurl = "https://" + uurl
//                                }
//                                targetUrls.insert(uurl)
//                            }
//                        }
//
//                        let urlssData = (try? JSONEncoder().encode(Array(targetUrls))) ?? Data()
//                        resp = Response(http: HTTPResponse(status: HTTPResponseStatus.ok, body:  HTTPBody(data: urlssData)), using: req)
//                        return resp
//                    })

//                }
//                print("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx")
//                print(targetUrls.count)
//                print(targetUrls)
//            let urlssData = (try? JSONEncoder().encode(Array(targetUrls))) ?? Data()
//            return  Response(http: HTTPResponse(status: HTTPResponseStatus.ok, body:  HTTPBody(data: urlssData)), using: req)
////            return try Array(targetUrls).encode(for: req)
//        })
//        let id = try?   req.parameters.next(Int.self)
//        return "requested id #\(id ?? 0)"
        return result2!
    }
    func getJDGoodsUrls1(urls : [String] , _ req : Request) throws   -> EventLoopFuture<Response>{
        var targetUrls = Set<String>()
        
        DispatchQueue.global().async {
            for url in urls {
                //wait 不能再事件循环里调用,要再子线程里调用,比如.globall里
                let result = try? req.client().get(url).wait()//wait() must not be called when on an EventLoop
                //            result?.map({ (rep) -> (String) in
                print(".....................................")
                let bodyyy = result?.http.body
                if let data = bodyyy?.data{
                    var bodyString  = String(data: data, encoding: String.Encoding.utf8) ?? ""
                    if bodyString.count <= 0 {
                        let cfEnc = CFStringEncodings.GB_18030_2000
                        let enc = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(cfEnc.rawValue))
                        //                    let str = String(data: data!, encoding: String.Encoding(rawValue: enc))
                        bodyString  = String(data: data, encoding: String.Encoding.init(rawValue: enc)) ?? ""
                    }
                    //                (https://\\w+.jd.com/[\\w/]+.html)|
                    let goodsPattern = "(\\w+.jd.com[\\w/\\\\]*.html)|(https://\\w+.jd.com/[\\w/]*.html)"//有的链接被转义了,\\\\是匹配转义字符
                    //如 : item.jd.com\/22283934451.html
                    let reg = try? NSRegularExpression(pattern:goodsPattern, options: [NSRegularExpression.Options.allowCommentsAndWhitespace,NSRegularExpression.Options.caseInsensitive])
                    let arr = reg?.matches(in: bodyString, options: NSRegularExpression.MatchingOptions.init(rawValue: 0), range: NSMakeRange(0, bodyString.count))
                    //                    print(url)
                    
                    for i in arr ?? []{
                        //                    print(i.range)
                        var uurl = NSString(string: bodyString).substring(with:
                            i.range)
                        uurl = uurl.replacingOccurrences(of: "\\", with: "")
                        if !(uurl.hasPrefix("http")){
                            uurl = "https://" + uurl
                        }
                        targetUrls.insert(uurl)
                        //                        print(uurl)
                    }
                    //                    if url == "https://nong.jd.com"{
                    //                        print(bodyString)
                    //                    }
                    //                print(bodyString)//取请求体body
                }
                
                //                return "vv"
                //            })
            }
            print("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx")
            print(targetUrls.count)
            print(targetUrls)
        }
        return try Array(targetUrls).encode(for: req)
        return try "".encode(for: req)
    }
    
    
    
    
    
    
    
    
    
    
    
    func getUrlsOfJD(_ req : Request) -> String {
        let url = "http://www.jd.com"
        let result = try? req.client().get(url)
        result?.map({ (rep) -> (String) in
            print(".....................................")
            let bodyyy = rep.http.body
            if let data = bodyyy.data{
                var bodyString  = String(data: data, encoding: String.Encoding.utf8) ?? "空空空"
                let pattern = "(https://yp.jd.com/\\w+.html)"
                let goodsPattern = "(https://item.jd.com/\\w+.html)"
                let reg = try? NSRegularExpression(pattern: "(href=\"//[\\w.&;\\#]+\">)", options: [NSRegularExpression.Options.allowCommentsAndWhitespace,NSRegularExpression.Options.caseInsensitive])
                //                bodyString = "https://yp.jd.com/737684bb8e2dce70341.html"
                let arr = reg?.matches(in: bodyString, options: NSRegularExpression.MatchingOptions.init(rawValue: 0), range: NSMakeRange(0, bodyString.count))
                var urlss = [String]()
                for i in arr ?? []{
                    //                    print(i.range)
                    var uurl = NSString(string: bodyString).substring(with:
                        i.range)
                    uurl = uurl.replacingOccurrences(of: "&#47;", with: "/") ;
                    uurl = uurl.replacingOccurrences(of: "&#47", with: "/") ;
                    uurl = uurl.replacingOccurrences(of: "href=\"", with: "https:")
                    uurl = uurl.replacingOccurrences(of: ";\">", with: "")
                    uurl = uurl.replacingOccurrences(of: "\">", with: "")
                    //                    print(uurl)
                    urlss.append(uurl)
                    //                    DispatchQueue.global().async {
                    //                        self.getJDGoodsUrl(url: uurl, req)
                    //                    }
                }
                self.getJDGoodsUrls(urls: urlss, req)
                //                print(bodyString)//取请求体body
            }
            print(".....................................")
            return "xx"
        })
        let id = try?   req.parameters.next(Int.self)
        return "requested id #\(id ?? 0)"
    }
    func getJDGoodsUrls(urls : [String] , _ req : Request)  {
        var targetUrls = Set<String>()
        
        DispatchQueue.global().async {
            for url in urls {
                //wait 不能再时间循环里调用,要再子线程里调用,比如.globall里
                let result = try? req.client().get(url).wait()//wait() must not be called when on an EventLoop
                //            result?.map({ (rep) -> (String) in
                print(".....................................")
                let bodyyy = result?.http.body
                if let data = bodyyy?.data{
                    var bodyString  = String(data: data, encoding: String.Encoding.utf8) ?? ""
                    if bodyString.count <= 0 {
                        let cfEnc = CFStringEncodings.GB_18030_2000
                        let enc = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(cfEnc.rawValue))
                        //                    let str = String(data: data!, encoding: String.Encoding(rawValue: enc))
                        bodyString  = String(data: data, encoding: String.Encoding.init(rawValue: enc)) ?? ""
                    }
                    //                (https://\\w+.jd.com/[\\w/]+.html)|
                    let goodsPattern = "(\\w+.jd.com[\\w/\\\\]*.html)|(https://\\w+.jd.com/[\\w/]*.html)"//有的链接被转义了,\\\\是匹配转义字符
                    //如 : item.jd.com\/22283934451.html
                    let reg = try? NSRegularExpression(pattern:goodsPattern, options: [NSRegularExpression.Options.allowCommentsAndWhitespace,NSRegularExpression.Options.caseInsensitive])
                    let arr = reg?.matches(in: bodyString, options: NSRegularExpression.MatchingOptions.init(rawValue: 0), range: NSMakeRange(0, bodyString.count))
                    //                    print(url)
                    
                    for i in arr ?? []{
                        //                    print(i.range)
                        var uurl = NSString(string: bodyString).substring(with:
                            i.range)
                        uurl = uurl.replacingOccurrences(of: "\\", with: "")
                        if !(uurl.hasPrefix("http")){
                            uurl = "https://" + uurl
                        }
                        targetUrls.insert(uurl)
                        //                        print(uurl)
                    }
                    //                    if url == "https://nong.jd.com"{
                    //                        print(bodyString)
                    //                    }
                    //                print(bodyString)//取请求体body
                }
                
                //                return "vv"
                //            })
            }
            print("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx")
            print(targetUrls.count)
            print(targetUrls)
        }
        
    }
    
    
    func getJDGoodsUrl(url : String , _ req : Request)  {
        let result = try? req.client().get(url)
        result?.map({ (rep) -> (String) in
            print(".....................................")
            let bodyyy = rep.http.body
            if let data = bodyyy.data{
                var bodyString  = String(data: data, encoding: String.Encoding.utf8) ?? ""
                if bodyString.count <= 0 {
                    let cfEnc = CFStringEncodings.GB_18030_2000
                    let enc = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(cfEnc.rawValue))
                    //                    let str = String(data: data!, encoding: String.Encoding(rawValue: enc))
                    bodyString  = String(data: data, encoding: String.Encoding.init(rawValue: enc)) ?? ""
                }
                //                (https://\\w+.jd.com/[\\w/]+.html)|
                let goodsPattern = "(\\w+.jd.com[\\w/\\\\]*.html)|(https://\\w+.jd.com/[\\w/]*.html)"
                let reg = try? NSRegularExpression(pattern:goodsPattern, options: [NSRegularExpression.Options.allowCommentsAndWhitespace,NSRegularExpression.Options.caseInsensitive])
                let arr = reg?.matches(in: bodyString, options: NSRegularExpression.MatchingOptions.init(rawValue: 0), range: NSMakeRange(0, bodyString.count))
                print(url)
                
                for i in arr ?? []{
                    //                    print(i.range)
                    var uurl = NSString(string: bodyString).substring(with:
                        i.range)
                    
                    print(uurl)
                }
                if url == "https://nong.jd.com"{
                    print(bodyString)
                }
                //                print(bodyString)//取请求体body
            }
            
            return "vv"
        })
    }
    
}
