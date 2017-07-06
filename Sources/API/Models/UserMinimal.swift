//
//  UserMinimal.swift
//  kayako-messenger-SDK
//
//  Created by Robin Malhotra on 15/02/17.
//  Copyright © 2017 Robin Malhotra. All rights reserved.
//

import Foundation
import Unbox

public struct UserMinimal: Unboxable {

	public let id: Int
	public let fullName: String
	public let avatar: URL
	public let lastActiveAt: Date
	
	/// Initialize an instance of this model by unboxing a dictionary using an Unboxer
	public init(unboxer: Unboxer) throws {
		self.id = try unboxer.unbox(key: "id")
		self.fullName = try unboxer.unbox(key: "full_name")
		self.avatar = try unboxer.unbox(key: "avatar")
		self.lastActiveAt = try iso8601Date(unboxer: unboxer, key: "last_active_at")
	}
	
	public var firstName: String? {
		return self.fullName.components(separatedBy: " ").first
	}
}

extension UserMinimal: Equatable {
	static public func ==(lhs: UserMinimal, rhs: UserMinimal) -> Bool {
		return lhs.id == rhs.id
	}
}
