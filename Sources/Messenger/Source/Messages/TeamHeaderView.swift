//
//  TeamHeaderView.swift
//  kayako-messenger-SDK
//
//  Created by Robin Malhotra on 25/04/17.
//  Copyright © 2017 Robin Malhotra. All rights reserved.
//

import AsyncDisplayKit


struct TeamHeaderModel {
	public let brandName: String
	public let activity: String
	
	init(brandName: String, activity: String) {
		self.brandName = brandName
		self.activity = activity
	}
	
	init(_ starterData: StarterData, _ configuration: Configuration) {
		self.brandName = configuration.brandName
		self.activity = "We typically reply in \(replyTimeString(for: starterData.averageReplyTime))"
	}
}

func replyTimeString(for time: Float) -> String {
	if time < 15 * 60 {
		return "15 minutes"
	} else {
		return "under a day"
	}
}

class TeamHeaderNode: ASDisplayNode {
	
	let brandNode = ASTextNode()
	let timeNode = ASTextNode()
	
	func load(teamHeaderModel: TeamHeaderModel)	{

		brandNode.attributedText = NSAttributedString(string: teamHeaderModel.brandName, attributes: KayakoLightStyle.MessageHeaderAttributes.teamStyle)
		self.addSubnode(brandNode)
		
		timeNode.attributedText = NSAttributedString(string: teamHeaderModel.activity, attributes: KayakoLightStyle.MessageHeaderAttributes.timeStyle)
		self.addSubnode(timeNode)
		
		
		transitionLayout(withAnimation: true, shouldMeasureAsync: false, measurementCompletion: nil)

	}
	
	override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
		return ASStackLayoutSpec(direction: .vertical, spacing: 1, justifyContent: .center, alignItems: .center, children: [brandNode, timeNode])
	}
}
