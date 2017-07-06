//
//  SendButtonDelegate.swift
//  Kayako
//
//  Created by Robin Malhotra on 16/03/17.
//  Copyright © 2017 Kayako. All rights reserved.
//

import Foundation

public protocol ReplyBoxDelegate: class {
	func sendButtonTapped(with text: String, textView: ALTextView)
	func attachmentButtonTapped()
}
