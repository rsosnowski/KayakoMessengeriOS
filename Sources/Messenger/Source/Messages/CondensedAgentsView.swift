//
//  CondensedAgentsView.swift
//  kayako-messenger-SDK
//
//  Created by Robin Malhotra on 26/04/17.
//  Copyright © 2017 Robin Malhotra. All rights reserved.
//

import AsyncDisplayKit
import PINCacheTexture

struct CondensedAgentViewModel {
	let agentAvatars: [(avatar: AvatarViewModel, isOnline: Bool)]
	
	init(agentAvatars: [(avatar: AvatarViewModel, isOnline: Bool)]) {
		self.agentAvatars = agentAvatars
	}
	
	init(_ starterData: StarterData) {
		self.agentAvatars = starterData.lastActiveAgents.flatMap {
			guard case .object(let agent) = $0 else {
				return nil
			}
			return (avatar: .url(agent.avatar), isOnline: false)
		}
	}
}

class CondensedAgentView: ASDisplayNode {
	
	var avatarNodes: [ASNetworkImageNode] = []
	
	func load(_ condensedAgentViewModel: CondensedAgentViewModel) {
		
		for node in self.subnodes {
			node.removeFromSupernode()
		}
		
		self.avatarNodes = condensedAgentViewModel.agentAvatars.map {
			let imageNode = ASNetworkImageNode()
			switch $0.0 {
			case .image(let image):
				imageNode.image = image
			case .url(let url):
				imageNode.setImageURL(url)
			}
			imageNode.style.width = ASDimensionMake(32)
			imageNode.style.height = ASDimensionMake(32)
			imageNode.cornerRadius = 16.0
			imageNode.clipsToBounds = true
			return imageNode
		}
		
		for avatarNode in self.avatarNodes {
			self.addSubnode(avatarNode)
		}
		transitionLayout(withAnimation: false, shouldMeasureAsync: true, measurementCompletion: nil)
	}
	
	override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
		return ASStackLayoutSpec(direction: .horizontal, spacing: -16, justifyContent: .end, alignItems: .center, children: avatarNodes)
	}
}
