//
//  ConversationsSource.swift
//  kayako-messenger-SDK
//
//  Created by Robin Malhotra on 20/05/17.
//  Copyright © 2017 Robin Malhotra. All rights reserved.
//

import Foundation
import Unbox

class ConversationsSource {
	
	static var shared = ConversationsSource(client: Client.shared, kreClient: KREClient.shared)
	
	let client: Client
	let kreClient: KREClient
	
	var unreadCountTotal = 0
	
	var downloadTask: URLSessionTask?
	var typingIndicators: [Int: [AvatarViewModel]] = [:]
	
	
	init(client: Client, kreClient: KREClient) {
		self.client = client
		self.kreClient = kreClient
	}
	
	var conversations: [Int: Conversation] = [:] {
		didSet {
			
			let oldKeys = self.keys
			self.keys = conversations.keys.sorted(by: { (key1, key2) -> Bool in
				guard let conversation1 = conversations[key1],
					let conversation2 = conversations[key2] else {
						return true
				}
				return conversation1.lastUpdatedAt.compare(conversation2.lastUpdatedAt) == .orderedDescending
			})
			
			let keysDiff = oldKeys.diff(other: self.keys)
			if kreClient.socket.isConnected {
				KREClientSetup(keysDiff: keysDiff, oldValue: oldValue)
			} else {
				kreClient.connect {
					[weak self] in
					self?.KREClientSetup(keysDiff: keysDiff, oldValue: oldValue)
				}
			}
			
			NotificationCenter.default.post(name: KayakoNotifications.conversationsInsertedOrDeleted, object: self, userInfo: ["diff": keysDiff])
			
			let indicesToRefresh = keysDiff.commonIndexes.indexPathsInSection(section: 0)
			.map {
				return $0.row
			}.filter { (index) -> Bool in
				let conversationID = self.keys[index]
				guard let oldConversation = oldValue[conversationID],
					let newConversation = self.conversations[conversationID] else {
						return false
				}
				
				if newConversation.lastMessagePreview != oldConversation.lastMessagePreview ||
					newConversation.lastAgentReplier != oldConversation.lastAgentReplier ||
					newConversation.lastRepliedAt != oldConversation.lastRepliedAt {
					return true
				} else {
					return false
				}
			}
			NotificationCenter.default.post(name: KayakoNotifications.conversationsUpdated, object: self, userInfo: ["indices": indicesToRefresh])
			
			self.top3Conversations = self.keys.first3.flatMap{ self.conversations[$0] }
			
			let unreadCountTotal = conversations.reduce(0) { (result, kvPair) in
				return result + kvPair.value.unreadCount
			}
			self.unreadCountTotal = unreadCountTotal
			NotificationCenter.default.post(name: KayakoNotifications.unreadCountUpdated, object: self, userInfo: ["count": unreadCountTotal])
		}
	}
	
	func KREClientSetup(keysDiff: ArrayDiff, oldValue: [Int: Conversation]) {
		let inserts = keysDiff.insertedIndexes.indexPathsInSection(section: 0).map{ $0.row }
		let deletes = keysDiff.removedIndexes.indexPathsInSection(section: 0).map{ $0.row }
		for insertedIndex in inserts {
			let id = keys[insertedIndex]
			guard let conversation = conversations[id] else {
				return
			}
			let channel = kreClient.socket.channel(conversation.realtimeChannel)
			channel.join()?.receive("ok") {
				[weak self] payload in
				guard let strongSelf = self else { return }
				strongSelf.kreClient.addChangeCallback(topic: conversation.realtimeChannel, closure: { (_) in
					strongSelf.conversationChangeReceived(url: conversation.resourceURL)
				})
				
				strongSelf.kreClient.addNewPostCallback(topic: conversation.realtimeChannel, closure: { (messageID) in
					NotificationCenter.default.post(name: KayakoNotifications.newPostReceieved, object: self, userInfo: ["conversationID": conversation.id, "messageID": messageID])
				})
				
				strongSelf.kreClient.addPresenceStateCallback(topic: conversation.realtimeChannel) {
					state in
					let typingAgents: [AvatarViewModel] = state
						.flatMap {
							meta in
							return meta.value
						}
						.filter {
							meta in
							return meta["is_typing"] as? Bool == true
						}
						.flatMap {
							typingMeta in
							let unboxer = Unboxer(dictionary: typingMeta)
							guard let avatar: URL = try? unboxer.unbox(keyPath: "user.avatar"),
								case .object(let creator) = conversation.creator,
								let userID: Int = try? unboxer.unbox(keyPath: "user.id"),
								creator.id != userID,
								let isTyping = typingMeta["is_typing"] as? Bool,
								isTyping == true else {
									return nil
							}
							return .url(avatar)
						}
					
					if typingAgents.count > 0 {
						print("asdfsadf")
					}
					self?.typingIndicators[conversation.id] = typingAgents
					NotificationCenter.default.post(name: KayakoNotifications.conversationTypingIndicator, object: self, userInfo: ["conversationID": conversation.id])
				}
			}
			channel.join()?.receive("error", callback: { (payload) in
				print(payload)
			})
		}
		
		for deletedIndex in deletes {
			let id = keys[deletedIndex]
			guard let conversation = oldValue[id] else {
				return
			}
			let channel = kreClient.socket.channel(conversation.realtimeChannel)
			channel.leave()?.receive("ok") {
				_ in
			}
		}
	}
	
	func conversationChangeReceived(url: URL) {
		client.load(resource: NetworkResource<Conversation>.url(url)) {
			[weak self] result in
			switch result {
			case .success(let conversation):
				if let oldConversation = self?.conversations[conversation.id] {
					self?.conversations[conversation.id] = conversation
					if oldConversation.isClosed == false && conversation.isClosed == true {
						NotificationCenter.default.post(name: KayakoNotifications.conversationCompleted, object: self, userInfo: ["conversationID": conversation.id])
					}
					if conversation.statusID == 4 && oldConversation.statusID != 4 {
						NotificationCenter.default.post(name: KayakoNotifications.conversationCompleted, object: self, userInfo: ["conversationID": conversation.id])
					}
				}
			case .failure(let error):
				print(error)
			}
		}
	}
	
	func setData(_ data: [Conversation]) {
		let tempDict = data.reduce([:]) { (result, conversation) -> [Int: Conversation] in
			var dict = result
			dict[conversation.id] = conversation
			return dict
		}
		self.conversations = tempDict
	}

	var keys: [Int] = []
	
	var top3Conversations: [Conversation] = [] {
		didSet {
			NotificationCenter.default.post(name: KayakoNotifications.top3Updated, object: self, userInfo: ["conversations": top3Conversations])
		}
	}
	
	
	func loadConversationsIfNecessary(force: Bool = false) {
		
		if let task = downloadTask {
			task.cancel()
		}
		
		if force == false && conversations.count != 0 {
			return
		}
		
		downloadTask = client.loadArray(resource: MultiResource<[Conversation]>.paginated(parents: [], offset: nil, limit: nil)) { (result) in
			switch result {
			case .success(let conversations):
				let serviceGroup = DispatchGroup()
				for var conversation in conversations {
					serviceGroup.enter()
					self.client.loadIfNecessary(resources: [conversation.creator, conversation.lastReplier, conversation.requester], resourceLoaded: { (result) in
					}, onAllResources: { (results) in
						if case .success(let creator) = results[0]  {
							conversation.creator = .object(creator)
						}
						if case .success(let lastReplier) = results[1]  {
							conversation.lastReplier = .object(lastReplier)
						}
						if case .success(let requester) = results[2] {
							conversation.requester = .object(requester)
						}
						serviceGroup.leave()
					})
				}
				serviceGroup.notify(queue: .main, execute: {
					self.setData(conversations)
				})
			case .failure(let error):
				print(error)
			}
		}
	}
}
