//
//  ConversationsDataSource.swift
//  kayako-messenger-SDK
//
//  Created by Robin Malhotra on 21/02/17.
//  Copyright © 2017 Robin Malhotra. All rights reserved.
//

import AsyncDisplayKit


class ConversationsDataSource: NSObject, ASTableDataSource {
	
	weak var controller: ConversationsViewController?
	
	func numberOfSections(in tableNode: ASTableNode) -> Int {
		return 1
	}
	
	func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
		return ConversationsSource.shared.keys.count
	}
	
	func load() {
		ConversationsSource.shared.loadConversationsIfNecessary()
		
		NotificationCenter.default.addObserver(forName: KayakoNotifications.conversationsInsertedOrDeleted, object: nil, queue: .main) { [weak self] (notification) in
			guard let diff = notification.userInfo?["diff"] as? ArrayDiff else {
				return
			}
			
			let inserts = diff.insertedIndexes.indexPathsInSection(section: 0) as [IndexPath]
			let deletes = diff.removedIndexes.indexPathsInSection(section: 0) as [IndexPath]
			self?.controller?.tableNode.insertRows(at: inserts, with: .fade)
			self?.controller?.tableNode.deleteRows(at: deletes, with: .fade)
		}
		
		NotificationCenter.default.addObserver(forName: KayakoNotifications.conversationsUpdated, object: nil, queue: .main) { (notification) in
			guard let indices = notification.userInfo?["indices"] as? [Int] else {
				return
			}
			
			let indexPaths = indices.map{ IndexPath(row: $0, section: 0) }
			self.controller?.tableNode.reloadRows(at: indexPaths, with: .fade)
		}
	}
	
	func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
		let id = ConversationsSource.shared.keys[indexPath.row]
		guard let conversation = ConversationsSource.shared.conversations[id],
		case .object(let user) = conversation.lastReplier else { return ASCellNode() }
		
		let viewModel = ConversationViewModel(id: conversation.id, avatarURL: user.avatar, lastMessage: conversation.lastMessagePreview, name: user.fullName, time: conversation.lastRepliedAt.timeAgoInWords(), unreadCount: conversation.unreadCount)
		
		return ConversationCellNode(conversation: viewModel, separatorInset: UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18))
	}
}
