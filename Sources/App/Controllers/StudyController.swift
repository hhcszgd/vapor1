//
//  StudyController.swift
//  App
//
//  Created by WY on 2019/8/5.
//

import Vapor
class StudyController {

    func handlePostRequest(_ req : Request ,_ para: DDRequestModel) -> DDRequestModel {
        return para
    }
   
    func handleGetRequest(_ req : Request) -> String {
        let id = try?   req.parameters.next(Int.self)
        return "requested id #\(id ?? 0)"
    }
    func ttt()  {
    
         Abort(.badRequest, reason: "Could not get data from external API.")
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
