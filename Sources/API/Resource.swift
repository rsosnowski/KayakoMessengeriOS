//
//  Resource.swift
//  kayako-messenger-SDK
//
//  Created by Robin Malhotra on 15/02/17.
//  Copyright © 2017 Robin Malhotra. All rights reserved.
//

import Foundation
import Unbox

public enum Resource<T> where T: Unboxable & Equatable {
	case notLoaded(NetworkResource<T>)
	case object(T)
}

extension Resource: Unboxable {
	/// Initialize an instance of this model by unboxing a dictionary using an Unboxer
	public init(unboxer: Unboxer) throws {
		if let object = try? unbox(dictionary: unboxer.dictionary) as T {
			self = Resource.object(object)
		} else if let url: URL = try? unboxer.unbox(key: "resource_url") {
			self = Resource.notLoaded(NetworkResource.url(url))
		} else {
			let id: Int = try unboxer.unbox(key: "id")
			self = Resource.notLoaded(NetworkResource.id(parents: [], id: id))
		}
	}
	
}

extension Resource: Equatable {
	
	public static func ==(lhs: Resource<T>, rhs: Resource<T>) -> Bool {
		
		switch (lhs, rhs) {
		case (.notLoaded(let lhs), .notLoaded(let rhs)):
			return lhs == rhs
		case (.object(let lhs), .object(let rhs)):
			return lhs == rhs
		default:
			break
		}
		return false
	}

}
