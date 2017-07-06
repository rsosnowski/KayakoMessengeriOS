//
//  HomeScreenDataSource.swift
//  kayako-messenger-SDK
//
//  Created by Robin Malhotra on 08/02/17.
//  Copyright © 2017 Robin Malhotra. All rights reserved.
//

import AsyncDisplayKit


enum LoadingState {
	case loading
	case loaded(StarterData)
	case error(Error)
}

open class HomeScreenDataSource: NSObject, ASTableDataSource {
	
	var client: Client
	weak var controller: HomeScreenViewController?
	var state: LoadingState = .loading
	var timer: Timer?
	
	let configuration: Configuration
	
	init(client: Client, configuration: Configuration) {
		self.client = client
		self.configuration = configuration
		super.init()
		
		if #available(iOS 10.0, *) {
			timer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: false) { [weak self] (timer) in
				self?.load()
			}
		} else {
			timer = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(load), userInfo: nil, repeats: false)
		}
		timer?.fire()

	}
	
	public func load() {
		client.load(resource: NetworkResource<StarterData>.standalone) { (result) in
			switch result {
			case .failure(let error):
				self.state = .error(error)
			case .success(let starterData):
				self.state = .loaded(starterData)
				self.controller?.tableNode.reloadRows(at: [IndexPath.init(row: 2, section: 0)], with: .fade)
			}
		}
		
		ConversationsSource.shared.loadConversationsIfNecessary()

		NotificationCenter.default.addObserver(forName: KayakoNotifications.top3Updated, object: nil, queue: .main) { (notification) in
			self.controller?.tableNode.reloadRows(at: [IndexPath.init(row: 1, section: 0)], with: .fade)
		}
	}
	
	public func numberOfSections(in tableNode: ASTableNode) -> Int {
		return 1
	}
	
	public func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
		return [1,2,3].count
	}
	
	public func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
		switch indexPath.row {
		case 0:
			let message = WelcomeMessage(message: configuration.homeTitle, subtext: configuration.homeSubtitle)
			return WelcomeHeader(message)
		case 1:
			let conversations = ConversationsSource.shared.top3Conversations
			let conversationModels: [ConversationViewModel] = conversations.flatMap { conversation in
				switch conversation.lastReplier {
				case .object(let replier):
					return ConversationViewModel(id: conversation.id, avatarURL: replier.avatar, lastMessage: conversation.lastMessagePreview, name: replier.fullName, time: conversation.lastRepliedAt.timeAgoInWords(), unreadCount: conversation.unreadCount)
				default:
					return nil
				}
			}
			
			if conversationModels.count == 0 {
				return ASCellNode()
			} else {
				return {
					let node = RecentConversationsNode(conversations: conversationModels)
					for node in node.conversationNodes {
						node.tappedDelegate = self
					}
					node.headerNode.viewAllTappedDelegate = self
					return node
				}()
			}
		case 2:
			let agentModels: [UserMinimal] = {
				switch state {
				case .loaded(let starterData):
					return starterData.lastActiveAgents.flatMap {
						if case .object(let user) = $0 {
							return user
						} else {
							return nil
						}
					}
				default:
					return []
				}
			}()
			
			if agentModels.count == 0 {
				return ASCellNode()
			}
			
			return {
				let node = AgentsOnlineNode(agents: agentModels)
				return node
			}()
		default:
			return ASCellNode()
		}
	}
	
	func conversationTapped(_ conversationVM: ConversationViewModel, sender: RecentConversationsCell) {
		
		guard case .loaded(let starterData) = state else {
			return
		}
		
		guard let conversation = ConversationsSource.shared.conversations[conversationVM.id] else { return }
		
		let messagesVC = MessagesViewController(resource: .object(conversation), configuration: configuration, starterData: starterData)
		controller?.navigationController?.pushViewController(messagesVC, animated: true)
		
	}
	
	func viewAllTapped() {
		if case .loaded(let starterData) = state, let configuration = controller?.configuration {
			controller?.navigationController?.pushViewController(ConversationsViewController.init(starterData: starterData, configuration: configuration), animated: true)
		}
	}
	
}
