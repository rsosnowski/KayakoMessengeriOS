//
//  WelcomeHeader.swift
//  kayako-messenger-SDK
//
//  Created by Robin Malhotra on 08/02/17.
//  Copyright © 2017 Robin Malhotra. All rights reserved.
//

import AsyncDisplayKit

public struct WelcomeMessage {
	public let message: String
	public let subtext: String
}

open class WelcomeHeader: ASCellNode {
	
	let welcomeMessageNode: ASTextNode
	let subtextMessageNode: ASTextNode
	
	init(_ welcomeMessage: WelcomeMessage) {
		self.welcomeMessageNode = ASTextNode()
		self.subtextMessageNode = ASTextNode()
		
		super.init()
		
		self.selectionStyle = .none
		self.addSubnode(welcomeMessageNode)
		self.addSubnode(subtextMessageNode)
		
		reload(with: welcomeMessage)
	}
	
	func reload(with welcomeMessage: WelcomeMessage) {
		welcomeMessageNode.attributedText = NSAttributedString(string: welcomeMessage.message, attributes: [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont.preferredFont(forTextStyle: .title1)])
		subtextMessageNode.attributedText = NSAttributedString(string: welcomeMessage.subtext, attributes: KayakoLightStyle.HomescreenAttributes.welcomeSubtitleStyle)
	}
	
	override open func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
		let stack = ASStackLayoutSpec(direction: .vertical, spacing: 16, justifyContent: .spaceBetween, alignItems: .stretch, children: [welcomeMessageNode, subtextMessageNode])
		return ASInsetLayoutSpec(insets: UIEdgeInsetsMake(18, 18, 18, 18), child: stack)
	}
}
