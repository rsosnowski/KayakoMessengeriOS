//
//  MessageContainerCellNode.swift
//  kayako-messenger-SDK
//
//  Created by Robin Malhotra on 09/05/17.
//  Copyright © 2017 Robin Malhotra. All rights reserved.
//

import AsyncDisplayKit


class MessageContainerCellNode: ASCellNode {
	let messageNode: MessageCellNode
	let attachmentNodes: [AttachmentCellNode]
	
	let isSender: Bool
	let messageViewModel: MessageViewModel
	
	
	//FIXME: Refactor this when PGDD ends
	init(messageViewModel: MessageViewModel, shouldShowAvatar: Bool = true, delegate controller: AttachmentTapHandler?, client: Client? = nil) {
		self.messageViewModel = messageViewModel
		self.messageNode = MessageCellNode(messageViewModel: messageViewModel, shouldShowAvatar: shouldShowAvatar)
		self.attachmentNodes = messageViewModel.attachments.map {
			let node = AttachmentCellNode(attachmentViewModel: $0, client: client)
			return node
		}
		
		self.isSender = messageViewModel.isSender
		super.init()
		
		
		self.addSubnode(messageNode)
		for node in attachmentNodes {
			node.delegate = controller
			node.layer.borderColor = KayakoLightStyle.MessageAttributes.senderMessageBackgroundColor.cgColor
			node.layer.borderWidth = 1.0
			node.clipsToBounds = true
			node.cornerRadius = 4.0
			if case .sending = messageViewModel.replyState {
				node.alpha = 0.6
			}
			if case .yetToSend = messageViewModel.replyState {
				node.alpha = 0.6
			}
			self.addSubnode(node)
		}
		
	}
	
	override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
		let attachmentSpecs:[ASLayoutElement] = attachmentNodes.map {
			if self.isSender {
				//FIXME: PGDD Hack, fix later
				return ASInsetLayoutSpec(insets: UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 18), child: $0)
			} else {
				return ASInsetLayoutSpec(insets: UIEdgeInsets.init(top: 0, left: 59, bottom: 0, right: 0), child: $0)
			}
		}
		
		let isFileNameSame = messageViewModel.contentText == messageViewModel.attachments.first?.name
		var fileNameComponents = messageViewModel.attachments.first?.name.components(separatedBy: ".")
		fileNameComponents?.removeLast()
		let isFileNameWOExtensionSame = fileNameComponents?.joined() == messageViewModel.contentText
		
		let shouldShowFileNameAsMessage = (attachmentSpecs.count == 1) && (isFileNameSame || isFileNameWOExtensionSame)
		
		let spacer = ASLayoutSpec()
		spacer.style.height = ASDimensionMake(4.0)
		spacer.style.width = ASDimensionMakeWithFraction(1.0)
		
		let elements: [ASLayoutElement] = (shouldShowFileNameAsMessage ? [spacer] : [messageNode as ASLayoutElement]) + attachmentSpecs
		if self.isSender {
			return ASStackLayoutSpec(direction: .vertical, spacing: 4.0, justifyContent: .start, alignItems: .end, children: elements)
		} else {
			return ASStackLayoutSpec(direction: .vertical, spacing: 4.0, justifyContent: .start, alignItems: .start, children: elements)
		}
	}
}
