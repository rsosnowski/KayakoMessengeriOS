//
//  TypingIndicator.swift
//  kayako-messenger-SDK
//
//  Created by Robin Malhotra on 17/04/17.
//  Copyright © 2017 Robin Malhotra. All rights reserved.
//

import AsyncDisplayKit

class TypingIndicator: ASCellNode {
	
	let textNode = ASTextNode()
	
	
	func setText(agentFirstNames: [String]) {
		func subject(for array: [String]) -> String {
			switch array.count {
			case 1:
				return array[0]
			case 2:
				return array[0] + "and" + array[1]
			default:
				return "several"
			}
		}
		
		func verb(for array: [String]) -> String {
			switch array.count {
			case 1:
				return "is"
			default:
				return "are"
			}
		}
		
		let text = [subject(for: agentFirstNames), verb(for: agentFirstNames), " typing"].joined(separator: " ")
		
		let attrString = NSMutableAttributedString.init(string: text, attributes: KayakoLightStyle.MessageStatusAttributes.typingIndicator)
		attrString.setAttributes(KayakoLightStyle.MessageStatusAttributes.typingIndicatorBold, range: NSMakeRange(0, subject(for: agentFirstNames).characters.count))
		textNode.attributedText = attrString
	}
}
