//
//  TypingIndicatorMessageCell.swift
//  kayako-messenger-SDK
//
//  Created by Robin Malhotra on 23/05/17.
//  Copyright © 2017 Robin Malhotra. All rights reserved.
//

import AsyncDisplayKit
import NVActivityIndicatorView
import PINCacheTexture
//67x52 27x24
class TypingIndicatorMessageCell: ASCellNode {
	
	let indicatorNode = ASDisplayNode { () -> UIView in
		let view = UIView()
		let indicator = NVActivityIndicatorView(frame: CGRect(x: 67/2 - 27/2, y: 52/2 - 24/2, width: 27, height: 24), type: .ballPulse, color: ColorPallete.tertiaryTextColor, padding: 0.0)
		indicator.startAnimating()
		view.addSubview(indicator)
		return view
	}
	
	let avatarNode = ASNetworkImageNode()
	
	override init() {
		super.init()
		self.automaticallyManagesSubnodes = true
		indicatorNode.style.width = ASDimensionMake(67)
		indicatorNode.style.height = ASDimensionMake(52)
		indicatorNode.layer.cornerRadius = 4.0
		avatarNode.clipsToBounds = true
		avatarNode.style.width = ASDimensionMake(32)
		avatarNode.style.height = ASDimensionMake(32)
		avatarNode.layer.cornerRadius = 16.0
		indicatorNode.backgroundColor = KayakoLightStyle.MessageAttributes.senderMessageBackgroundColor
		indicatorNode.clipsToBounds = true
	}
	
	func load(avatar: AvatarViewModel) {
		switch avatar {
		case .image(let image):
			avatarNode.image = image
		case .url(let url):
			avatarNode.setImageURL(url)
		}
	}
	
	override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
		let stack = ASStackLayoutSpec(direction: .horizontal, spacing: 9.0, justifyContent: .start, alignItems: .center, children: [avatarNode, indicatorNode])
		return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 4, left: 18, bottom: 4, right: 4), child: stack)
	}
}
