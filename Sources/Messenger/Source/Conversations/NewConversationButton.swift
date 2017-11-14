//
//  NewConversationButton.swift
//  kayako-messenger-SDK
//
//  Created by Robin Malhotra on 05/03/17.
//  Copyright © 2017 Robin Malhotra. All rights reserved.
//

import AsyncDisplayKit

class NewConversationButton: ASButtonNode {
	
	var onTap: (() -> Void)?
	let animationDamping = CGFloat(0.5)
	let animationSpringVelocity = CGFloat(0.4)
	let animationDuration = 0.5
	
	override init() {
		
		super.init()
		self.backgroundColor = ColorPallete.primaryBrandingColor
		self.clipsToBounds = true
		self.layer.cornerRadius = 20

		self.imageNode.style.width = ASDimensionMake(20)
		self.imageNode.style.width = ASDimensionMake(20)
		self.setTitle("Start a new conversation", with: UIFont.systemFont(ofSize: FontSize.subHeading, weight: UIFontWeight.semibold), with: .white, for: [])
		self.setImage(KayakoResources.newConversation.image, for: [])
	}
	
	override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
		
		let stack = ASStackLayoutSpec(direction: .horizontal, spacing: 9, justifyContent: .center, alignItems: .center, children: [titleNode, imageNode])
		return ASInsetLayoutSpec(insets: UIEdgeInsets.init(top: 0, left: 0, bottom: 1, right: 0), child: stack)
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//		UIView.animate(withDuration: animationDuration, delay: 0.0, usingSpringWithDamping: animationDamping, initialSpringVelocity: animationSpringVelocity, options: [], animations: {
//			self.view.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
//			self.backgroundColor = UIColor(red:0.83, green:0.38, blue:0.22, alpha:1.00)
//		}, completion: nil)
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//		UIView.animate(withDuration: animationDuration, delay: 0.0, usingSpringWithDamping: animationDamping, initialSpringVelocity: animationSpringVelocity, options: [], animations: {
//			self.view.transform = .identity
//			self.backgroundColor = ColorPallete.primaryBrandingColor
//		}, completion: nil)
		sendActions(forControlEvents: .touchUpInside, with: nil)
	}
	
	override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
		UIView.animate(withDuration: animationDuration, delay: 0.0, usingSpringWithDamping: animationDamping, initialSpringVelocity: animationSpringVelocity, options: [], animations: {
			self.backgroundColor = ColorPallete.primaryBrandingColor
			self.view.transform = .identity
		}, completion: nil)
	}
}
