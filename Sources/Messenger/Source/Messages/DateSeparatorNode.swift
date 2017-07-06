//
//  DateSeparatorNode.swift
//  kayako-messenger-SDK
//
//  Created by Robin Malhotra on 05/06/17.
//  Copyright © 2017 Robin Malhotra. All rights reserved.
//

import AsyncDisplayKit

class DateSeparatorNode: ASCellNode {
	
	let dateTextNode = ASTextNode()
	
	init(date: Date) {
		super.init()
		let formatter = DateFormatter()
		formatter.timeStyle = .none
		formatter.dateStyle = .medium
		dateTextNode.attributedText = NSAttributedString(string: formatter.string(from: date), attributes: KayakoLightStyle.DateSeparatorAttributes.dateSeparatorTextStyle)
		self.automaticallyManagesSubnodes = true
	}
	
	override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
		let stack = ASStackLayoutSpec(direction: .horizontal, spacing: 0.0, justifyContent: .center, alignItems: .center, children: [dateTextNode])
		return ASInsetLayoutSpec(insets: UIEdgeInsets.init(top: 4, left: 4, bottom: 4, right: 4), child: stack)
	}
}
