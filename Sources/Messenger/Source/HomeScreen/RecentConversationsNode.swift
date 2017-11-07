//
//  RecentConversationsNode.swift
//  kayako-messenger-SDK
//
//  Created by Robin Malhotra on 08/02/17.
//  Copyright © 2017 Robin Malhotra. All rights reserved.
//

import AsyncDisplayKit
import PINCacheTexture

public struct ConversationViewModel {
	let id: Int
	let avatarURL: URL
	let lastMessage: String
	let name: String
	let time: String
	let unreadCount: Int
}

open class RecentConversationsNode: ASCellNode {
	
	let conversations: [ConversationViewModel]
	var conversationNodes: [RecentConversationsCell] = []
	let headerNode = ConversationHeaderCell(headingText: "RECENT CONVERSATIONS", subheadingText: "View all →")
	let container = ASDisplayNode()
	
	let backgroundNode = ASDisplayNode { () -> UIView in
		let effect = UIBlurEffect(style: .extraLight)
		let vibrancyEffect = UIVibrancyEffect(blurEffect: effect)
		
		let visualEffectView = UIVisualEffectView(effect: effect)
		let vibrancyView = UIVisualEffectView(effect: vibrancyEffect)
		vibrancyView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		visualEffectView.backgroundColor = .clear
		visualEffectView.contentView.addSubview(vibrancyView)
		return visualEffectView
	}
	
	init(conversations: [ConversationViewModel]) {
		self.conversations = conversations
		super.init()
		self.backgroundColor = .clear
		self.selectionStyle = .none
		conversationNodes = conversations.map(RecentConversationsCell.init)
		container.addSubnode(backgroundNode)
		container.addSubnode(headerNode)
		
		conversationNodes.forEach(container.addSubnode)
		self.addSubnode(container)
		
		container.clipsToBounds = true
		container.layer.cornerRadius = 6.0
		
		container.layoutSpecBlock = {
			[weak self] size in
			guard let strongSelf = self else { return ASLayoutSpec() }
			let elements = [strongSelf.headerNode as ASLayoutElement] + strongSelf.conversationNodes.map{ $0 as ASLayoutElement }
			let stack = ASStackLayoutSpec(direction: .vertical, spacing: 0.0, justifyContent: .start, alignItems: .stretch, children: elements)
			let bg =  ASBackgroundLayoutSpec(child: stack, background: strongSelf.backgroundNode)
			return ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 0, 0, 0), child: bg)
		}
	
	}
	
	open override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
		let stack = ASStackLayoutSpec(direction: .vertical, spacing: 0.0, justifyContent: .center, alignItems: .stretch, children: [container])
		return stack
	}
}

open class UnreadCounterNode: ASDisplayNode {
	let textNode = ASTextNode()
	
	public override init() {
		super.init()
		self.automaticallyManagesSubnodes = true
		self.backgroundColor = ColorPallete.primaryBrandingColor
		self.layer.cornerRadius = 9.0
		self.style.minWidth = ASDimensionMake(24)
		self.style.height = ASDimensionMake(18)
		self.clipsToBounds = true
	}
	
	func load(count: Int) {
		let countToShow = count > 9 ? "+9" : "\(count)"
		self.textNode.attributedText = NSAttributedString(string: countToShow, attributes: KayakoLightStyle.HomescreenAttributes.unreadIndicatorStyle)
	}
	
	open override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
		return ASStackLayoutSpec(direction: .vertical, spacing: 0.0, justifyContent: .center, alignItems: .center, children: [textNode])
	}
}


open class RecentConversationsCell: ASCellNode {
	
	let conversation: ConversationViewModel
	
	let avatarNode = ASNetworkImageNode()
	let nameNode = ASTextNode()
	let latestMessageNode = ASTextNode()
	let timeNode = ASTextNode()
	let unreadCounterNode = UnreadCounterNode()
	let separatorLine = ASDisplayNode()
	
	public weak var tappedDelegate: HomeScreenDataSource?
	
	init(conversation: ConversationViewModel) {
		self.conversation = conversation
		super.init()
		
		avatarNode.setImageURL(conversation.avatarURL)
		nameNode.attributedText = NSAttributedString(string: conversation.name, attributes: KayakoLightStyle.HomescreenAttributes.nameStyle)
		latestMessageNode.attributedText = NSAttributedString(string: conversation.lastMessage, attributes: KayakoLightStyle.HomescreenAttributes.bodyStyle)
		latestMessageNode.maximumNumberOfLines = 1
		
		timeNode.attributedText = NSAttributedString(string: conversation.time, attributes: KayakoLightStyle.HomescreenAttributes.lightSubtextStyle)
		
		avatarNode.style.width = ASDimensionMake(32)
		avatarNode.style.height = ASDimensionMake(32)
		
		avatarNode.layer.cornerRadius = 16.0
		avatarNode.clipsToBounds = true
		
		separatorLine.style.width = ASDimensionMakeWithFraction(1.0)
		separatorLine.style.height = ASDimensionMake(1.0)
		separatorLine.backgroundColor = UIColor.black.withAlphaComponent(0.09)
		
		let tapGR = UITapGestureRecognizer(target: self, action: #selector(tapped))
		self.view.addGestureRecognizer(tapGR)
		self.unreadCounterNode.load(count: self.conversation.unreadCount)
		
		self.automaticallyManagesSubnodes = true
	}
	
	func tapped(sender: UITapGestureRecognizer) {
		tappedDelegate?.conversationTapped(conversation, sender: self)
		switch sender.state {
		case .began:
			self.backgroundColor = UIColor.white.withAlphaComponent(0.8)
		case .ended:
			self.backgroundColor = UIColor.white.withAlphaComponent(0.0)
		default:
			break
		}
	}
	
	override open func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
		let nameAndTime = ASStackLayoutSpec(direction: .horizontal, spacing: 0.0, justifyContent: .spaceBetween, alignItems: .stretch, children: [nameNode, timeNode])
		
		let subjectAndUnreadChildren = (self.conversation.unreadCount == 0) ? [latestMessageNode as ASLayoutElement] : [latestMessageNode, unreadCounterNode] as [ASLayoutElement]
		latestMessageNode.style.flexShrink = 0.1
		let subjectAndUnread = ASStackLayoutSpec(direction: .horizontal, spacing: 16.0, justifyContent: .spaceBetween, alignItems: .start, children: subjectAndUnreadChildren)
		subjectAndUnread.style.flexGrow = 1.0
		subjectAndUnread.style.flexShrink = 1.0
		
		
		let nameAndSubject = ASStackLayoutSpec(direction: .vertical, spacing: 5.0, justifyContent: .start, alignItems: .stretch, children: [nameAndTime, subjectAndUnread as ASLayoutElement])
		nameAndSubject.style.flexGrow = 1.0
		nameAndSubject.style.flexShrink = 1.0
		let stack = ASStackLayoutSpec(direction: .horizontal, spacing: 9.0, justifyContent: .start, alignItems: .center, children: [avatarNode, nameAndSubject])
		
		let inset = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(9, 18, 9, 18), child: stack)
		return ASStackLayoutSpec(direction: .vertical, spacing: 0.0, justifyContent: .start, alignItems: .stretch, children: [inset, separatorLine])
	}
}

class ConversationHeaderCell: ASDisplayNode {
	let productUpdatesNode = ASTextNode()
	let viewAllNode = ASButtonNode()
	
	weak var viewAllTappedDelegate: HomeScreenDataSource?
	
	init(headingText: String, subheadingText: String) {
		super.init()
		
		self.addSubnode(productUpdatesNode)
		self.addSubnode(viewAllNode)
		viewAllNode.hitTestSlop = UIEdgeInsetsMake(-9, -9, -9, -9)
		
		self.backgroundColor = UIColor.white.withAlphaComponent(0.75)
		
		productUpdatesNode.attributedText = NSAttributedString(string: headingText, attributes: KayakoLightStyle.HomescreenAttributes.widgetHeadingStyle)
		viewAllNode.setAttributedTitle(NSAttributedString(string: subheadingText, attributes: KayakoLightStyle.HomescreenAttributes.widgetSubHeadingStyle), for: .normal)
		viewAllNode.addTarget(self, action: #selector(self.viewAllTapped), forControlEvents: .touchUpInside)
		self.style.height = ASDimensionMake(34.0)
	}
	
	func viewAllTapped() {
		viewAllTappedDelegate?.viewAllTapped()
	}
	
	override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
		let stack = ASStackLayoutSpec(direction: .horizontal, spacing: 0.0, justifyContent: .spaceBetween, alignItems: .center, children: [productUpdatesNode, viewAllNode])
		return ASInsetLayoutSpec(insets: UIEdgeInsetsMake(9, 18, 9, 18), child: stack)
	}
}
