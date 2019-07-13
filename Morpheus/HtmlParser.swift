//
//  HtmlParser.swift
//  Cake
//
//  Created by Dennis John on 9/8/16.
//  Copyright © 2016 Lips Labs. All rights reserved.
//

import Foundation
import Alamofire

class HtmlParser {
    
    
    static func getGoogleSearchPage(searchTerm: String, complete: @escaping ([String])->()) {
        
        let searchURL = URL(string: "https://www.google.com/search?client=safari&rls=en&q=\(searchTerm)&ie=UTF-8&oe=UTF-8&num=30")
        
        let headers: HTTPHeaders = ["User-Agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 11_1 like Mac OS X) AppleWebKit/604.3.5 (KHTML, like Gecko) Mobile/15B93"]
        Alamofire.request(searchURL!, headers: headers)
            .responseString { response in
                complete(parseGoogleResults(html: response.result.value!))
        }
    }
    
    //parses google results and returns an array of urls
    static func parseGoogleResults(html:String)->[String] {
        var ret = [String]()
        
        do {
            if let document = try? HTML(html: html, encoding: .utf8) {
                for element in document.xpath("//a[@class=\"C8nzq BmP5tf\"]/@href") {
                    if let elementText = element.text {
                        if elementText.starts(with: "http") && !ret.contains(elementText) {
                            ret.append(elementText)
                        }
                    }
                }
            }
        } catch _ {
        }
        return ret
    }
}
