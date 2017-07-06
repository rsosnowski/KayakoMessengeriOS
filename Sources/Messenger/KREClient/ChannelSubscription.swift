//
//  ChannelSubscription.swift
//  kayako-messenger-SDK
//
//  Created by Robin Malhotra on 22/03/17.
//  Copyright © 2017 Robin Malhotra. All rights reserved.
//

import Foundation
import Birdsong

public struct ChannelSubscription {
	
	let channelName: String
	
	var onNewPost: ((Int) -> Void)?
	var onChange: ((Response) -> Void)?
	var onPresenceStateChange: ((Presence) -> Void)?
}
