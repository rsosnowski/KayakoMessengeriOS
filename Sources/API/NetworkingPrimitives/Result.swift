//
//  Result.swift
//  kayako-messenger-SDK
//
//  Created by Robin Malhotra on 15/02/17.
//  Copyright © 2017 Robin Malhotra. All rights reserved.
//

import Unbox

public enum Result<T> {
	case success(T)
	case failure(Error)
}
