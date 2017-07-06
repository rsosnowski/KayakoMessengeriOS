//
//  URLSession+Validation.swift
//  kayako-messenger-SDK
//
//  Created by Robin Malhotra on 09/04/17.
//  Copyright © 2017 Robin Malhotra. All rights reserved.
//

import Foundation

public extension URLSession {
	func validatedDataTask(with request: URLRequest, completion: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
		return self.dataTask(with: request) { (data, response, error) in
			guard let httpResponse = response as? HTTPURLResponse else {
				return
			}
			if !(200..<300).contains(httpResponse.statusCode) ||  httpResponse.mimeType != "application/json"  {
				let error = NSError(domain: "com.kayako.customersuccess", code: 666, userInfo: ["data": String(data: data ?? Data(), encoding: .utf8) as Any, "url": request.url ?? URLRequest(url: URL(string: "support.kayako.com")!)])
				completion(data, response, error)
			} else {
				completion(data, response, error)
			}
		}
	}
}
