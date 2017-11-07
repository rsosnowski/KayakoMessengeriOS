//
//  MessagesHeaderView.swift
//  kayako-messenger-SDK
//
//  Created by Robin Malhotra on 24/04/17.
//  Copyright © 2017 Robin Malhotra. All rights reserved.
//
import AsyncDisplayKit
import PINCacheTexture

public struct AgentsHeaderModel {
	var avatars: [AvatarViewModel]
	let activityString: String
	
	init(avatars: [AvatarViewModel], activityString: String) {
		self.avatars = avatars
		self.activityString = activityString
	}
	
	init(starterData: StarterData) {
		self.avatars = starterData.lastActiveAgents.map {
			if case .object(let creator) = $0 {
				return .url(creator.avatar)
			} else {
				return .url(Production.shared.placeholderAvatarURL)
			}
		}
		
		let agentNames: [String] = starterData.lastActiveAgents.flatMap {
			if case .object(let agent) = $0 {
				return agent.firstName
			} else {
				return nil
			}
		}
		
		self.activityString = {
			agentFirstNames in
			if agentFirstNames.count > 2 {
				return "\(agentFirstNames.first!), \(agentFirstNames.second!) and \(agentFirstNames.third!) are online"
			} else if agentFirstNames.count == 2 {
				return "\(agentFirstNames.first!) and \(agentFirstNames.second!) are online"
			} else if agentFirstNames.count == 1 {
				return "\(agentFirstNames.first!) is online"
			} else {
				return ""
			}
		}(agentNames)
	
	}
}


public class AgentsHeaderView: ASDisplayNode {
	
	var avatarNodes: [ASNetworkImageNode] = []
	let activityNode = ASTextNode()
	
	func load(_ agentsHeaderModel: AgentsHeaderModel) {
		
		for node in self.subnodes {
			node.removeFromSupernode()
		}
		
		self.avatarNodes = agentsHeaderModel.avatars.map {
			let avatarImageNode = ASNetworkImageNode()
			switch $0 {
			case .image(let image):
				avatarImageNode.image = image
			case .url(let url):
				avatarImageNode.setImageURL(url)
			}
			avatarImageNode.style.width = ASDimensionMake(52)
			avatarImageNode.style.height = ASDimensionMake(52)
			avatarImageNode.layer.cornerRadius = 26
			avatarImageNode.clipsToBounds = true
			return avatarImageNode
		}

		self.activityNode.attributedText = NSAttributedString(string: agentsHeaderModel.activityString, attributes: KayakoLightStyle.MessageHeaderAttributes.activityStyle)
		
		for avatarNode in avatarNodes {
			self.addSubnode(avatarNode)
		}
		self.addSubnode(activityNode)
		
		transitionLayout(withAnimation: true, shouldMeasureAsync: false, measurementCompletion: nil)
	}
	
	public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
		let avatarsSpec = ASStackLayoutSpec(direction: .horizontal, spacing: 9, justifyContent: .center, alignItems: .center, children: avatarNodes)
		let headingText = ASStackLayoutSpec(direction: .vertical, spacing: 1, justifyContent: .center, alignItems: .center, children: [activityNode])
		
		avatarsSpec.style.spacingBefore = 13.0
		avatarsSpec.style.spacingAfter = 3.0
		return ASStackLayoutSpec(direction: .vertical, spacing: 4.0, justifyContent: .center, alignItems: .stretch, children: [avatarsSpec, headingText])
	}
}
