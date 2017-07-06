//
//  Parser.swift
//  kayako-messenger-SDK
//
//  Created by Robin Malhotra on 17/02/17.
//  Copyright © 2017 Robin Malhotra. All rights reserved.
//

import Foundation
import Unbox

enum ParserError: Error {
	case dataIsNilOrNonDict(data: Data?)
	case typeNotUnboxable
}

struct Parser {
	static let shared = Parser()
	
	func parseArray<T>(data: Data?) throws -> Result<[T]> where T: Unboxable {
		do {
			guard let currentData = data else {
				throw ParserError.dataIsNilOrNonDict(data: data)
			}
			let conversations: [T] = try unbox(data: currentData, atKeyPath: "data", allowInvalidElements: false)
			return Result<[T]>.success(conversations)
			
		} catch {
			return Result.failure(error)
		}
	}
	
	func parse<T>(data: Data?) throws -> Result<T> where T: Unboxable {
		do {
			guard let currentData = data else {
				throw ParserError.dataIsNilOrNonDict(data: data)
			}
			let jsonDict = try JSONSerialization.jsonObject(with: currentData, options: [.allowFragments, .mutableContainers, .mutableLeaves])
			guard let json = jsonDict as? [String: Any] else {
				throw ParserError.dataIsNilOrNonDict(data: data)
			}
			let x: T = try unbox(dictionary: json, atKey: "data")
			return Result.success(x)
		} catch {
			return Result.failure(error)
		}
	}
	
}
