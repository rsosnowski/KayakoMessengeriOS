//
//  ConversationCellNode.swift
//  kayako-messenger-SDK
//
//  Created by Robin Malhotra on 22/02/17.
//  Copyright © 2017 Robin Malhotra. All rights reserved.
//

import AsyncDisplayKit
import PINCacheTexture

class ConversationCellNode: ASCellNode {

	let conversation: ConversationViewModel
	
	let avatarImageNode = ASNetworkImageNode()
	let nameNode = ASTextNode()
	let timeNode = ASTextNode()
	let lastMessageNode = ASTextNode()
	let unreadCounterNode = UnreadCounterNode()
	
	init(conversation: ConversationViewModel, separatorInset: UIEdgeInsets) {
		self.conversation = conversation
		super.init()

		avatarImageNode.setImageURL(conversation.avatarURL)
		
		nameNode.attributedText = NSAttributedString(string: conversation.name, attributes: KayakoLightStyle.ConversationAttributes.nameStyle)
		timeNode.attributedText = NSAttributedString(string: conversation.time, attributes: KayakoLightStyle.ConversationAttributes.lightSubtextStyle)
		lastMessageNode.attributedText = NSAttributedString(string: conversation.lastMessage, attributes: KayakoLightStyle.ConversationAttributes.bodyStyle)
		lastMessageNode.maximumNumberOfLines = 2
		lastMessageNode.style.flexShrink = 0.01
		
		avatarImageNode.style.width = ASDimensionMake(52)
		avatarImageNode.style.height = ASDimensionMake(52)
		avatarImageNode.layer.cornerRadius = 26.0
		avatarImageNode.clipsToBounds = true
		
		self.unreadCounterNode.load(count: conversation.unreadCount)
		self.separatorInset = separatorInset
		self.automaticallyManagesSubnodes = true
	}
	
	override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
		let nameAndTime = ASStackLayoutSpec(direction: .horizontal, spacing: 0.0, justifyContent: .spaceBetween, alignItems: .stretch, children: [nameNode, timeNode])
		let bottomHalfElements = self.conversation.unreadCount == 0 ? [lastMessageNode as ASLayoutElement] : [lastMessageNode, unreadCounterNode]  as [ASLayoutElement]
		let lastMessageAndCounter = ASStackLayoutSpec(direction: .horizontal, spacing: 9.0, justifyContent: .spaceBetween, alignItems: .center, children: bottomHalfElements)
		let nameAndLastMessage = ASStackLayoutSpec(direction: .vertical, spacing: 2.0, justifyContent: .center, alignItems: .stretch, children: [nameAndTime, lastMessageAndCounter])
		nameAndLastMessage.style.flexGrow = 1.0
		nameAndLastMessage.style.flexShrink = 1.0
		let avatarAndContent = ASStackLayoutSpec(direction: .horizontal, spacing: 15.0, justifyContent: .spaceAround, alignItems: .center, children: [avatarImageNode, nameAndLastMessage])
		return ASInsetLayoutSpec(insets: UIEdgeInsets.init(top: 15, left: 18, bottom: 15, right: 18), child: avatarAndContent)
	}
	
}
