//
//  Pathable.swift
//  kayako-messenger-SDK
//
//  Created by Robin Malhotra on 19/02/17.
//  Copyright © 2017 Robin Malhotra. All rights reserved.
//

import Foundation

protocol Pathable {
	func path() -> (path: String, params: [String: String])
}
