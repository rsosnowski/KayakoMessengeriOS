//
//  Router.swift
//  kayako-messenger-SDK
//
//  Created by Robin Malhotra on 16/02/17.
//  Copyright © 2017 Robin Malhotra. All rights reserved.
//

import Foundation

public struct Router {
	let baseURL: String
	let APIProtocol = "https://"
	let apiPrefix = "api/v1/"
	let conversations = "conversations"
	let users = "users"
	let messages = "messages"
	let ratings = "ratings"
	
	func url<T>(for resource: NetworkResource<T>, includes: [ResourceName]) -> URL {
		
		switch resource {
		case .url(let url):
			let includeQueryItem = {
				return [URLQueryItem(name: "include", value: includes.reduce(""){ $0 + "\($1),"})]
			}()
			var components = URLComponents(string: url.absoluteString)
			components?.queryItems = includeQueryItem
			if let url = components?.url{
				return url
			} else {
				#if DEBUG
					fatalError("incorrect components \(String(describing: components)) for url: \(url)")
				#else
					return URL(string: "https://support.kayako.com")!
				#endif
			}
		default:
			let (path,queryDict) = resource.path()
			return url(from: path, queryDict: queryDict, includes: includes)
		}
		
	}
	
	func url<T>(for resource: MultiResource<T>, includes: [ResourceName]) -> URL {
		let (path,queryDict) = resource.path()
		return url(from: path, queryDict: queryDict, includes: includes)
	}
	
	private func url(from path: String, queryDict: [String: String], includes: [ResourceName]) -> URL {
		let starting = APIProtocol + [baseURL, apiPrefix].joined(separator: "/") + path
		let includeQueryItem = {
			return [URLQueryItem(name: "include", value: includes.reduce(""){ $0 + "\($1),"})]
		}()
		let queryParams = queryDict.map { return URLQueryItem(name: $0, value: $1) } + includeQueryItem
		var components = URLComponents(string: starting)
		components?.queryItems = queryParams != [] ? queryParams : nil
		if let url = components?.url{
			return url
		} else {
			#if DEBUG
				fatalError("URL Incorrect: \(starting + path)")
			#else
				return URL(string: "https://support.kayako.com")!
			#endif
		}
	}
	
	func url<T>(for creation: Creation<T>, includes: [ResourceName]) -> URL {
		let urlString: String = {
			switch creation {
			case .conversation(_):
				return APIProtocol + [baseURL, apiPrefix].joined(separator: "/") + conversations
			case .message(_, let conversationID):
				return APIProtocol + [baseURL, apiPrefix + conversations, "\(conversationID)", messages].joined(separator: "/")
			case .rating(_, let conversationID):
				return APIProtocol + [baseURL, apiPrefix + conversations, "\(conversationID)", ratings].joined(separator: "/")
			}
		}()
		
		if let _ = URL(string: urlString) {
			let queryParams: [URLQueryItem] = {
				if includes == [] {
					return []
				} else {
					return [URLQueryItem(name: "include", value: includes.reduce(""){ $0 + "\($1),"})]
				}
			}()
			var components = URLComponents(string: urlString)
			components?.queryItems = queryParams != [] ? queryParams : nil
			if let url = components?.url{
				return url
			} else {
				#if DEBUG
					fatalError("URL Incorrect: \(urlString) + \(queryParams)")
				#else
					return URL(string: "https://support.kayako.com")!
				#endif
			}
		} else {
			#if DEBUG
				fatalError("URL Incorrect: \(APIProtocol + [baseURL, apiPrefix].joined(separator: "/"))")
			#else
				return URL(string: "https://support.kayako.com")!
			#endif
		}
	}
	//: Continue adding other urls here
	//: PGDD starts here
	
	func updateRatingURL(ratingID: Int, conversationID: Int) -> URL {
		let urlString = APIProtocol + [baseURL, apiPrefix, conversations, "\(conversationID)", ratings, "\(ratingID)"].joined(separator: "/")
		if let url = URL(string: urlString) {
			return url
		} else {
			#if DEBUG
				fatalError("URL Incorrect: \(urlString)")
			#else
				return URL(string: "https://support.kayako.com")!
			#endif
		}
	}
	
}
