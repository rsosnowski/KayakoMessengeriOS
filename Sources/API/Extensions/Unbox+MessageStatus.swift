//
//  Unbox+MessageStatus.swift
//  kayako-messenger-SDK
//
//  Created by Robin Malhotra on 30/04/17.
//  Copyright © 2017 Robin Malhotra. All rights reserved.
//

import Unbox

func messageStatus(unboxer: Unboxer, key: String) throws -> MessageStatus? {
	let statusString: String = try unboxer.unbox(key: key)
	return MessageStatus(text: statusString)
}
