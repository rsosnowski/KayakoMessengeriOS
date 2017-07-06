//
//  String+EmailValidation.swift
//  kayako-messenger-SDK
//
//  Created by Robin Malhotra on 19/04/17.
//  Copyright © 2017 Robin Malhotra. All rights reserved.
//

import Foundation

public extension String {
	
	var isEmail: Bool {
		let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
		return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: self)
	}
}
