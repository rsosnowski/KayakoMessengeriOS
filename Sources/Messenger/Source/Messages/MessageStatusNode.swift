//
//  MessageStatusNode.swift
//  kayako-messenger-SDK
//
//  Created by Robin Malhotra on 16/04/17.
//  Copyright © 2017 Robin Malhotra. All rights reserved.
//

import AsyncDisplayKit


class MessageStatusNode: ASCellNode {
	
	let statusTextNode = ASTextNode()
	var statusImage = ASImageNode()
	let isSender: Bool
	
	init(status: MessageStatus, isSender: Bool) {
		self.isSender = isSender
		super.init()
		
		switch status {
		case .failed, .bounced:
			let attrString = NSMutableAttributedString(string: status.statusText, attributes: KayakoLightStyle.MessageStatusAttributes.grayedOutStyle)
			attrString.addAttributes([NSForegroundColorAttributeName: ColorPallete.primaryFailureColor], range: NSMakeRange(attrString.string.characters.count - "Resend".characters.count, "Resend".characters.count))
			statusTextNode.attributedText = attrString
		case .delivered, .sending, .sent, .yetToSend, .custom:
			statusTextNode.attributedText = NSAttributedString(string: status.statusText, attributes: KayakoLightStyle.MessageStatusAttributes.grayedOutStyle)
		case .seen:
			statusTextNode.attributedText = NSAttributedString(string: status.statusText, attributes: KayakoLightStyle.MessageStatusAttributes.seenStyle)
		}
		
		self.addSubnode(statusTextNode)
		

		self.statusImage = ASImageNode()
		
		switch status {
		case .bounced, .failed, .delivered:
			statusImage.image = status.image
			statusImage.contentMode = .scaleAspectFit
			statusImage.style.width = ASDimensionMake(12)
			statusImage.style.height = ASDimensionMake(12)
			self.addSubnode(statusImage)
		default:
			break
		}		
	}
	
	override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
		let children = [statusTextNode, statusImage] as [ASLayoutElement?]
		let stack = ASStackLayoutSpec(direction: .horizontal, spacing: 4.0, justifyContent: (isSender ? .end : .start), alignItems: .center, children: children.flatMap{ $0 })
		if isSender {
			return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 18), child: stack)
		} else {
			return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 59, bottom: 0, right: 0), child: stack)
		}
	}
}
