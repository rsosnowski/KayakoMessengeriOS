//
//  Production.swift
//  kayako-messenger-SDK
//
//  Created by Robin Malhotra on 24/04/17.
//  Copyright © 2017 Robin Malhotra. All rights reserved.
//

import Foundation

public struct Production {
	let s3URL = URL(string: "https://assets.kayako.com/messenger")
	let kreURL = URL(string: "wss://kre.kayako.net/socket")
	
	public static let shared = Production()
	
	func assetURL(for string: String) -> URL? {
		return s3URL?.appendingPathComponent(string)
	}
	
	public var placeholderAvatarURL: URL? {
		return self.assetURL(for: "avatar.png")
	}
}
