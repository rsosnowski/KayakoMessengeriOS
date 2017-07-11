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
	let tapButton = ASButtonNode()
	let isSender: Bool
	weak var resendTapDelegate: MessagesDataSource?
	
	init(status: MessageStatus, isSender: Bool, resendTapDelegate: MessagesDataSource? = nil) {
		self.isSender = isSender
		self.resendTapDelegate = resendTapDelegate
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
		self.automaticallyManagesSubnodes = true
		self.statusImage = ASImageNode()
		
		if case .failed = status {
			let tapGR = UITapGestureRecognizer(target: self, action: #selector(initiateResend))
			self.view.addGestureRecognizer(tapGR)
		}
		
		switch status {
		case .bounced, .failed, .delivered:
			statusImage.image = status.image
			statusImage.contentMode = .scaleAspectFit
			statusImage.style.width = ASDimensionMake(12)
			statusImage.style.height = ASDimensionMake(12)
		default:
			break
		}
		tapButton.hitTestSlop = UIEdgeInsetsMake(-18, -9, -18, -9)
		tapButton.backgroundColor = .clear
	}
	
	func initiateResend() {
		resendTapDelegate?.initiateResend()
	}
	
	override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
		let children = [statusTextNode, statusImage] as [ASLayoutElement?]
		let stack = ASStackLayoutSpec(direction: .horizontal, spacing: 4.0, justifyContent: (isSender ? .end : .start), alignItems: .center, children: children.flatMap{ $0 })
		// need to do _one_ tiny thing with result before returning
		let inset: ASInsetLayoutSpec = {
			if isSender {
				return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 18), child: stack)
			} else {
				return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 59, bottom: 0, right: 0), child: stack)
			}
		}()
		//use inset here
		return ASOverlayLayoutSpec(child: inset, overlay: tapButton)
	}
}
