//
//  TypingDelegate.swift
//  kayako-messenger-SDK
//
//  Created by Robin Malhotra on 17/04/17.
//  Copyright © 2017 Robin Malhotra. All rights reserved.
//

import UIKit

public class TypingDelegate: NSObject, ALTextInputBarDelegate {
	
	weak var controller: MessagesViewController?
	let kreClient: KREClient
	let topic: String
	
	
	init(textInputBar: ALTextInputBar, kreClient: KREClient, topic: String) {
		self.kreClient = kreClient
		self.topic = topic
		super.init()
		textInputBar.delegate = self
	}
	
	public func textViewDidChange(textView: ALTextView) {
		kreClient.sendStartTypingEvent(to: topic)
	}
	
	public func textViewDidEndEditing(textView: ALTextView) {
		let deadline = DispatchTime.now() + .seconds(5)
		DispatchQueue.main.asyncAfter(deadline: deadline) { [weak self] in
			self?.stopTyping()
		}
	}
	
	
	public func textViewDidBeginEditing(textView: ALTextView) {
		kreClient.sendStartTypingEvent(to: topic)
	}
	
	func stopTyping() {
		kreClient.sendStopTypingEvent(to: topic)
	}
}
