//
//  KayakoType.swift
//  kayako-messenger-SDK
//
//  Created by Robin Malhotra on 17/02/17.
//  Copyright © 2017 Robin Malhotra. All rights reserved.
//

import Unbox

public protocol KayakoType: Unboxable{
	var id: String { get }
}
