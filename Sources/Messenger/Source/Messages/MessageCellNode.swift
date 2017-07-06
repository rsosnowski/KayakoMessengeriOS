//
//  MessageCellNode.swift
//  kayako-messenger-SDK
//
//  Created by Robin Malhotra on 28/02/17.
//  Copyright © 2017 Robin Malhotra. All rights reserved.
//

import AsyncDisplayKit

class MessageCellNode: ASCellNode, ASTextNodeDelegate {
	let textNode = ASTextNode()
	let avatarNode = ASNetworkImageNode()
	let messageViewModel: MessageViewModel
	
	public var customInsets: UIEdgeInsets?
	public var shouldShowAvatar: Bool
	
	init(messageViewModel: MessageViewModel, shouldShowAvatar: Bool = true) {
		self.messageViewModel = messageViewModel
		self.shouldShowAvatar = shouldShowAvatar
		super.init()
		self.addSubnode(textNode)
		
		self.addSubnode(avatarNode)
		avatarNode.style.width = ASDimensionMake(32)
		avatarNode.style.height = ASDimensionMake(32)
		avatarNode.layer.cornerRadius = 16.0
		textNode.clipsToBounds = true
		textNode.layer.cornerRadius = 4.0
		if !self.messageViewModel.contentText.containsOnlyEmoji {
			textNode.backgroundColor = messageViewModel.isSender ? ColorPallete.primaryBrandingColor : KayakoLightStyle.MessageAttributes.senderMessageBackgroundColor
		}
		load()
		self.selectionStyle = .none
	}
	
	func load() {
		
		let attrString: NSMutableAttributedString = {
			if self.messageViewModel.contentText.containsOnlyEmoji {
				return NSMutableAttributedString(string: messageViewModel.contentText, attributes:  KayakoLightStyle.MessageAttributes.emojiBodyTextStyle)
			} else {
				textNode.textContainerInset = UIEdgeInsetsMake(9, 9, 9, 9)
				textNode.backgroundColor = messageViewModel.isSender ? ColorPallete.primaryBrandingColor : KayakoLightStyle.MessageAttributes.senderMessageBackgroundColor
				return NSMutableAttributedString(string: messageViewModel.contentText, attributes: messageViewModel.isSender ? KayakoLightStyle.MessageAttributes.lightBodyTextStyle : KayakoLightStyle.MessageAttributes.darkBodyTextStyle)
			}
		}()
		
		let urlDetector = try? NSDataDetector(types: NSTextCheckingAllSystemTypes)
		urlDetector?
			.enumerateMatches(in: messageViewModel.contentText, options: NSRegularExpression.MatchingOptions.reportCompletion, range: NSRange(location: 0, length: messageViewModel.contentText.characters.count)) {result, flags, stop in
				if result?.resultType == NSTextCheckingResult.CheckingType.link, let url = result?.url {
					var linkAttributes = KayakoLightStyle.MessageAttributes.linkAttrs
					linkAttributes["TextLinkAttributeName"] = url
					attrString.addAttributes(linkAttributes, range: (result?.range)!)
				}
		}
		
		textNode.attributedText = attrString
		textNode.isUserInteractionEnabled = true
		textNode.linkAttributeNames = ["TextLinkAttributeName"]
		textNode.passthroughNonlinkTouches = true
		textNode.delegate = self
		avatarNode.clipsToBounds = true
		
		if self.shouldShowAvatar {
			switch messageViewModel.avatar {
			case .image(let image):
				avatarNode.image = image
			case .url(let url):
				avatarNode.setImageURL(url)
			}
		}
		
		if case .yetToSend = self.messageViewModel.replyState {
			self.alpha = 0.3
		} else if case .sending = self.messageViewModel.replyState {
			self.alpha = 0.3
		}
		
	}
	
	override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
		let spacer = ASLayoutSpec()
		spacer.style.minWidth = ASDimensionMake(60)
		
		let nodes: [ASLayoutElement]
		
		if self.messageViewModel.isSender {
			let textStack = ASStackLayoutSpec(direction: .vertical, spacing: 4.0, justifyContent: .start, alignItems: .end, children: [textNode])
			textStack.style.flexShrink = 0.1
			nodes = [spacer, textStack]
		} else {
			if self.shouldShowAvatar {
				nodes = [avatarNode, textNode, spacer]
			} else {
				let avatarSpacer = ASLayoutSpec()
				avatarSpacer.style.width = ASDimensionMake(32)
				avatarSpacer.style.height = ASDimensionMake(32)
				nodes = [avatarSpacer, textNode, spacer]
			}
		}
		
		spacer.style.flexGrow = 1.0
		textNode.style.flexShrink = 0.1
		
		let stack = ASStackLayoutSpec(direction: .horizontal, spacing: 9, justifyContent: .start, alignItems: self.messageViewModel.contentText.containsOnlyEmoji ? .center : .stretch, children: nodes)
		
		return ASInsetLayoutSpec(insets: customInsets ?? UIEdgeInsets.init(top: 3, left: 18, bottom: 0, right: 18), child: stack)
	}
	
	func textNode(_ textNode: ASTextNode, tappedLinkAttribute attribute: String, value: Any, at point: CGPoint, textRange: NSRange) {
		if let url = value as? URL {
			UIApplication.shared.openURL(url)
		}
	}
	
}
