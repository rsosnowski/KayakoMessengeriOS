//
//  MessagesDataSource.swift
//  kayako-messenger-SDK
//
//  Created by Robin Malhotra on 28/02/17.
//  Copyright © 2017 Robin Malhotra. All rights reserved.
//

import AsyncDisplayKit
import Unbox
import Birdsong


enum ConversationState {
	case new
	case askingQuestions(Queue<BotQuestionModel>, currentData: [String: Any])
	case loading(resource: NetworkResource<Conversation>)
	case loaded(Conversation, PendingMessagesOperations, FeedbackEventsHandler)
}

open class MessagesDataSource: NSObject, ASTableDataSource, ASTableDelegate, InputSubmissionHandler, ReplyBoxDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	
	let client: Client
	
	var conversationState: ConversationState
	var messagesDataContainer = MessagesDataContainer()
	
	//PGDD
	var haveMessagesBeenLoaded = false
	
	weak var controller: MessagesViewController? {
		didSet {
			load()
		}
	}
	var typingDelegate: TypingDelegate?
	
	var messagesUpdateTask: URLSessionDataTask?
	var caseUpdateMessageTask: URLSessionDataTask?
	
	init(resource: Resource<Conversation>, client: Client = .shared, controller: MessagesViewController? = nil) {
		
		self.client = client
		switch resource {
		case .notLoaded(let networkResource):
			self.conversationState = .loading(resource: networkResource)
			super.init()
		case .object(let conversation):
			let pendingMessagesOperations = PendingMessagesOperations(client: self.client, conversation: conversation)
			let feedbackHandler = FeedbackEventsHandler(client: self.client, conversationID: conversation.id)
			self.conversationState = .loaded(conversation, pendingMessagesOperations, feedbackHandler)
			super.init()
			//:Had to put this here because that's the only way I could access self
			pendingMessagesOperations.delegate = self
		}
		self.messagesDataContainer.dataSource = self
	}
	
	init(conversationState: ConversationState, client: Client = .shared, controller: MessagesViewController? = nil) {
		self.conversationState = conversationState
		self.client = client
		super.init()
		self.messagesDataContainer.dataSource = self
	}
	
	func updateTable(with diff: ArrayDiff) {
		let insertedIndices = diff.insertedIndexes.indexPathsInSection(section: 0)
		let removedIndices = diff.removedIndexes.indexPathsInSection(section: 0)
		
		guard insertedIndices.count > 0 || removedIndices.count > 0 else {
			return
		}
		self.controller?.tableNode.performBatchUpdates({
			if insertedIndices.count > 0 {
				self.controller?.tableNode.insertRows(at: insertedIndices as [IndexPath], with: .fade)
			}
			if removedIndices.count > 0 {
				self.controller?.tableNode.deleteRows(at: removedIndices as [IndexPath], with: .fade)
			}
		}) {
			completed in
			
			self.controller?.scrollToBottom()
		}
		
		
		if let last = self.messagesDataContainer.messages.keys.sorted().last,
			let message = messagesDataContainer.messages[last],
			case .loaded(let conversation, _, _) = conversationState {
				self.client.updateReadStatus(for: message.id, in: conversation.id, completion: { (result) in
					ConversationsSource.shared.loadConversationsIfNecessary(force: true)
			})
		}
		
		guard case .loaded(let conversation, _, _) = conversationState else {
			return
		}
		
		let creators: [UserMinimal] = self.messagesDataContainer.messages.keys.sorted().flatMap {
			guard let message = messagesDataContainer.messages[$0] else {
				return nil
			}
			if case .object(let creator) = message.creator,
				case .object(let conversationCreator) = conversation.creator,
				creator.id != conversationCreator.id {
				return creator
			} else {
				return nil
			}
		}
		
		if let lastAgentReplier = creators.last {
			self.controller?.updateHeaders(with: .agent(agent: lastAgentReplier, isOnline: false))
		}
	}
	
	func load() {
		
		switch conversationState {
		case .new:
			self.controller?.textInputBar.textView.becomeFirstResponder()
			if let configuration = controller?.configuration,
				case .fingerprints(_, let userInfo) = configuration.authorization,
				let userData = userInfo {
				self.conversationState = .askingQuestions(BotQuestions.auth.queue(), currentData: ["name": userData.name,"email": userData.email.rawValue])
			} else {
				let defaults = UserDefaults.standard
				if let email = defaults.object(forKey: "Kayako.UserLoginInfo.email") as? String,
					let name = defaults.object(forKey: "Kayako.UserLoginInfo.name") as? String {
					self.conversationState = .askingQuestions(BotQuestions.auth.queue(), currentData: ["name": name,"email": email])
				} else {
					self.conversationState = .askingQuestions(BotQuestions.notAuth.queue(), currentData: [:])
				}
			}
			askQuestion()
		case .askingQuestions(_):
			askQuestion()
			
		case .loading(let networkResource):
			client.load(resource: networkResource) {
				result in
				switch result {
				case .success(let conversation):
					let pendingMessagesOperations = PendingMessagesOperations(client: self.client, conversation: conversation)
					pendingMessagesOperations.delegate = self
					let feedbackHandler = FeedbackEventsHandler(client: self.client, conversationID: conversation.id)
					self.setupTypingDelegate()
					self.conversationState = .loaded(conversation, pendingMessagesOperations, feedbackHandler)
					self.load()
				case .failure(let error):
					print(error)
				}
			}
		case .loaded(let conversation, _, _):
			if	let replierResource = conversation.lastAgentReplier,
				case .object(let replier) = replierResource {
				self.controller?.updateHeaders(with: .agent(agent: replier, isOnline: false))
			} else if let starterData = controller?.starterData, let config = controller?.configuration {
				self.controller?.updateHeaders(with: .starterData(starterData, config))
			}
			
			self.setupTypingDelegate()
			loadMessages(for: conversation.id)
		}
	}
	
	func conversationCompleted() {
		guard self.messagesDataContainer.botFeedback == nil else {
			return
		}
		self.messagesDataContainer.botFeedback = BotFeedback(feedback: nil, feedbackText: nil)
	}
	
	func setupTypingDelegate() {
		if let controller = self.controller,
			case .loaded(let conversation, _, _) = self.conversationState {
			self.typingDelegate = TypingDelegate(textInputBar: controller.textInputBar, kreClient: ConversationsSource.shared.kreClient, topic: conversation.realtimeChannel)
		}
	}
	
	func loadMessages(for conversationID: Int) {
		
		client.loadArray(resource: MultiResource<[Message]>.paginated(parents: [("conversations", "\(conversationID)")], offset: nil, limit: nil)) { (result) in
			switch result {
			case .success(let messages):
				let serviceGroup = DispatchGroup()
				var tempMessagesDict: [Int: Message] = [:]
				for var message in messages {
					serviceGroup.enter()
					self.client.loadIfNecessary(resources: [message.creator], resourceLoaded: { _ in }) {
						results in
						if case .success(let creator) = results[0] {
							message.creator = .object(creator)
						}
						tempMessagesDict[message.id] = message
						serviceGroup.leave()
					}
				}
				serviceGroup.notify(queue: .main, execute: {
					self.messagesDataContainer.messages = tempMessagesDict
					
					self.setupTypingDelegate()
					
					guard case .loaded(let conversation, let pendingMessagesOperations, _) = self.conversationState else {
						return
					}
					if	let replierResource = conversation.lastAgentReplier,
						case .object(let replier) = replierResource {
						self.controller?.updateHeaders(with: .agent(agent: replier, isOnline: false))
					}
					
					NotificationCenter.default.addObserver(forName: KayakoNotifications.conversationTypingIndicator, object: nil, queue: .main, using: { (notification) in
						guard let userInfo = notification.userInfo,
						let conversationID = userInfo["conversationID"] as? Int else { return }
						if conversation.id == conversationID,
							let typingIndicators = ConversationsSource.shared.typingIndicators[conversationID] {
							self.messagesDataContainer.typingIndicators = typingIndicators
						}
					})
					
					NotificationCenter.default.addObserver(forName: KayakoNotifications.newPostReceieved, object: nil, queue: .main, using: { (notification) in
						if let userInfo = notification.userInfo,
							let conversationID = userInfo["conversationID"] as? Int,
							let messageID = userInfo["messageID"] as? Int,
							conversationID == conversation.id {
							pendingMessagesOperations.KREMessageReceived(messageID: messageID)
						}
					})
					
					NotificationCenter.default.addObserver(forName: KayakoNotifications.conversationCompleted, object: nil, queue: .main, using: { [weak self] (notification) in
						if let userInfo = notification.userInfo,
							let conversationID = userInfo["conversationID"] as? Int,
							conversationID == conversation.id {
							self?.conversationCompleted()
						}
					})
					
					self.haveMessagesBeenLoaded = true

					DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500), execute: {
						self.controller?.scrollToBottom()
						self.haveMessagesBeenLoaded = true
						self.controller?.stopLoading()
					})
				})
			case .failure(let error):
				print(error)
			}
		}
	}
	
	func postChanged(payload: Socket.Payload) {
		guard case let .loaded(conversation, _, _) = conversationState else {
			return
		}
		
		DispatchQueue.main.async {
			let resource = MultiResource<[Message]>.paginated(parents: [("conversations", "\(conversation.id)")], offset: 0, limit: 100)
			if let task = self.messagesUpdateTask {
				task.cancel()
			}
			self.messagesUpdateTask = self.client.loadArray(resource: resource)  { (result) in
				switch result {
				case .success(let messages):
					let serviceGroup = DispatchGroup()
					var tempMessagesDict: [Int: Message] = [:]
					for var message in messages {
						serviceGroup.enter()
						self.client.loadIfNecessary(resources: [message.creator], resourceLoaded: { _ in }) {
							results in
							if case .success(let creator) = results[0] {
								message.creator = .object(creator)
							}
							tempMessagesDict[message.id] = message
							serviceGroup.leave()
						}
					}
					serviceGroup.notify(queue: .main, execute: {
						self.messagesDataContainer.messages = tempMessagesDict
						if self.messagesDataContainer.botMessages.count != 0 {
							self.messagesDataContainer.pendingMessages.removeLast()
						}
					})
				case .failure(let error):
					print(error)
				}
			}
		}
	}
	
	func askQuestion() {
		guard case .askingQuestions(var queue, let currentData) = conversationState,
			let botQuestion = queue.dequeue() else {
				return
		}
		
		self.conversationState = .askingQuestions(queue, currentData: currentData)
		self.messagesDataContainer.botMessages.append(.question(botQuestion))
	}
	
	//MARK: tableNode DataSource Methods
	
	public func numberOfSections(in tableNode: ASTableNode) -> Int {
		return 1
	}
	
	public func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
		return messagesDataContainer.count
	}
	
	public func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
		let (_, row) = (indexPath.section, indexPath.row)
		
		let rowSubscript = row
		
		switch messagesDataContainer[rowSubscript] {
		case .botMessage(let botMessage):
			switch botMessage {
			case .answer(let answer):
				let answerViewModel = MessageViewModel(avatar: .url(Production.shared.placeholderAvatarURL), contentText: answer, isSender: true, replyState: .sent)
				let node = MessageCellNode(messageViewModel: answerViewModel)
				node.transform = tableNode.transform
				node.selectionStyle = .none
				return node
			case .question(let question):
				switch question.type {
				case .replyBoxInput(_):
					return ASCellNode()
				case .text(let textQuestion):
					let node = BotTextQuestionNode(question: textQuestion, state: question.state)
					node.submitDelegate = self
					node.transform = tableNode.transform
					node.selectionStyle = .none
					return node
				}
			}
		case .message(let message):
			guard case .object(let creator) = message.creator,
				case .loaded(let conversation, _, _) = self.conversationState,
				case .object(let conversationCreator) = conversation.creator else { return ASCellNode() }
			
			let messageVM = MessageViewModel(avatar: .url(creator.avatar) , attachments: message.attachments.map(Attachment.toViewModel), contentText: message.contentText, isSender: message.creator == conversation.creator, replyState: message.status ?? .sent)
			
			let node = MessageContainerCellNode(messageViewModel: messageVM, delegate: self, client: self.client)
			node.messageNode.shouldShowAvatar = self.messagesDataContainer.shouldDisplayAvatar(at: rowSubscript, senderID: conversationCreator.id)
			if node.messageNode.shouldShowAvatar {
				node.messageNode.customInsets = UIEdgeInsets.init(top: 9, left: 18, bottom: 0, right: 18)
			}
			node.selectionStyle = .none
			node.transform = tableNode.transform
			return node
		case .pendingMessage(let pendingMessage):
			guard case .loaded(let conversation, _, _) = self.conversationState,
				case .object(let conversationCreator) = conversation.creator else {
					return {
						return MessageContainerCellNode(messageViewModel: pendingMessage, delegate: nil)
					}()
			}
			
			let node = MessageContainerCellNode(messageViewModel: pendingMessage, delegate: self, client: self.client)
			node.messageNode.shouldShowAvatar = self.messagesDataContainer.shouldDisplayAvatar(at: rowSubscript, senderID: conversationCreator.id)
			node.selectionStyle = .none
			node.transform = tableNode.transform
			return node
		case .feedback(let botFeedback):
			let node = BotFeedbackQuestionNode(feedback: botFeedback)
			node.selectionStyle = .none
			if case .loaded(_, _, let feedbackHandler) = self.conversationState {
				node.eventHandler = feedbackHandler
			}
			return node
		case .dateSeparator(let date):
			let node = DateSeparatorNode(date: date)
			node.selectionStyle = .none
			return node
		case .typingIndicator(let avatarViewModel):
			let node = TypingIndicatorMessageCell()
			node.load(avatar: avatarViewModel)
			return node
		case .messageStatus(let status, let isSender):
			let node = MessageStatusNode(status: status, isSender: isSender, resendTapDelegate: self)
			node.selectionStyle = .none
			return node
		}
	}
	
	internal func submit(text: String) {
		guard case .askingQuestions(let queue, var currentData) = self.conversationState,
			let lastMessage = messagesDataContainer.botMessages.last else {
			return
		}
		
		if case .question(let question) = lastMessage {
			switch question.type {
			case .replyBoxInput(_):
				let answer = BotMessage.answer(text)
				let trimmedText = text.trimmingCharacters(in: .whitespaces)
//				let messageVM = MessageViewModel(avatar: .image(UIImage()), contentText: trimmedText, isSender: true, replyState: .sending)
				messagesDataContainer.botMessages.append(.answer(trimmedText))
//				messagesDataContainer.botMessages.append()

				currentData["subject"] = text
				currentData["contents"] = text
				currentData["channel"] = SourceChannel.MESSENGER.rawValue
				self.conversationState = .askingQuestions(queue, currentData: currentData)
			case .text(let textQuestion):
				let email = text
				guard let name = email.components(separatedBy: "@").first else { return }
				let lastIndex = messagesDataContainer.botMessages.endIndex - 1
				var newQuestion = textQuestion
				newQuestion.value = email
				if email.isEmail {
					currentData["email"] = email
					currentData["name"] = name
					self.conversationState = .askingQuestions(queue, currentData: currentData)
					messagesDataContainer.botMessages[lastIndex] = .question(.init(type: .text(newQuestion), state: .success))
					
					let userDefaults = UserDefaults.standard
					if let config = controller?.configuration,
						case .fingerprints(let fingerprintID, _) = config.authorization {
						let uuid = fingerprintID
						userDefaults.setValue(uuid, forKey: "Kayako.fingerprintID")
						userDefaults.setValue(email, forKey: "Kayako.UserLoginInfo.email")
						userDefaults.setValue(name, forKey: "Kayako.UserLoginInfo.name")
						userDefaults.synchronize()
					}
					//:PGDD Hack
					if let cell = controller?.tableNode.nodeForRow(at: IndexPath.init(row: messagesDataContainer.count - 1, section: 0)) as? BotTextQuestionNode  {
						cell.state = .success
					}
				} else {
					messagesDataContainer.botMessages[lastIndex] = .question(.init(type: .text(newQuestion), state: .failed))
					//:PGDD Hack
					if let cell = controller?.tableNode.nodeForRow(at: IndexPath.init(row: messagesDataContainer.count - 1, section: 0)) as? BotTextQuestionNode  {
						cell.state = .failed
					}
				}
				self.controller?.tableNode.performBatchUpdates({ 
					self.controller?.tableNode.reloadRows(at: [IndexPath.init(row: messagesDataContainer.count - 1, section: 0)], with: .fade)
				}) { _ in
					self.conversationState = .askingQuestions(queue, currentData: currentData)
				}
			}
		}
	
		guard queue.count == 0,
			let last = messagesDataContainer.botMessages.last else {
			defer {
				askQuestion()
			}
			return
		}
		
		if case .question(let question) = last,
			question.state != .success {
			return
		}
		
		do {
			self.controller?.textInputBar.text = ""
			let conversation: ConversationCreateModel = try unbox(dictionary: currentData) as ConversationCreateModel
			let creation = Creation<Conversation>.conversation(conversation)
			client.create(creation) {
				result in
				switch result {
				case .success(let conversation):
					let pendingMessagesOperations = PendingMessagesOperations(client: self.client, conversation: conversation)
					pendingMessagesOperations.delegate = self
					let feedbackHandler = FeedbackEventsHandler(client: self.client, conversationID: conversation.id)
					ConversationsSource.shared.conversations[conversation.id] = conversation
					self.conversationState = .loaded(conversation, pendingMessagesOperations, feedbackHandler)
					self.load()
				case .failure(let error):
					print(error)
				}
			}
		} catch {
			print(error)
		}
	}
	
	public func attachmentButtonTapped() {
		let imagePickerController = UIImagePickerController()
		imagePickerController.sourceType = .photoLibrary
		imagePickerController.modalPresentationStyle = .custom
		imagePickerController.transitioningDelegate = CardTransitioningDelegate()
		imagePickerController.delegate = self
		imagePickerController.allowsEditing = false
		self.controller?.present(imagePickerController, animated: true, completion: nil)
		
	}
	
	public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		picker.dismiss(animated: true, completion: nil)
	}
	
	public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
		picker.dismiss(animated: true, completion: nil)
		//FIXME PGDD CODE HERE.
		guard case .loaded(let conversation, let pendingMessagesOperation, _) = conversationState,
			case .object(let creator) = conversation.creator else {
			picker.dismiss(animated: true, completion: nil)
			return
		}
		
		guard let referenceURL = info[UIImagePickerControllerReferenceURL] as? URL,
			let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
				return
		}
		
		guard let components = URLComponents(url: referenceURL, resolvingAgainstBaseURL: false),
			let queryItems = components.queryItems else {
				return
		}
		
		
		let idQueryItem = queryItems.filter {
			$0.name.lowercased() == "id"
		}.first
		
		guard let imageName = idQueryItem?.value else { return }
		//can't condense because compiler goes crazy
		
		let attachment = AttachmentViewModel(name: imageName, type: .image(thumbnail: .image(image)), downloadURL: nil)
		let messageViewModel = MessageViewModel(avatar: .url(creator.avatar), attachments: [attachment], contentText: imageName, isSender: true, replyState: .yetToSend)
		messagesDataContainer.pendingMessages.append(messageViewModel)
		
		//self.controller?.scrollToBottom(additionalOffset: self.controller?.keyboardDelegate.bottomPadding ?? 0)
		self.controller?.textInputBar.text = ""
		if let textView = self.controller?.textInputBar.textView {
			self.controller?.textInputBar.textViewHeightChanged(textView: textView, newHeight: 75)
		}
		pendingMessagesOperation.addToQueue(message: messageViewModel)

	}
	
	func initiateResend() {
		var message = self.messagesDataContainer.pendingMessages[0]
		message.replyState = .sending
		self.messagesDataContainer.pendingMessages[0] = message
		if case .loaded(_, let pendingMessageOperations, _) = conversationState {
			pendingMessageOperations.pendingMessages.array[0] = message
			pendingMessageOperations.startSendingMessages()
		}
		self.controller?.tableNode.reloadRows(at: [IndexPath.init(row: messagesDataContainer.botMessages.count + messagesDataContainer.messages.count, section: 0)], with: .fade)
	}
	
	public func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
		switch messagesDataContainer[indexPath.row] {
		case .pendingMessage(_):
			if self.messagesDataContainer.pendingMessages.filter ({
				message in
				if case .failed = message.replyState {
					return true
				} else {
					return false
				}
			}).count > 0 {
				initiateResend()
			}
		default:
			break
		}
	}
	
	public func sendButtonTapped(with text: String, textView: ALTextView) {
		let trimmedText = text.trimmingCharacters(in: .whitespaces)
		guard trimmedText != "" else { return }
		self.controller?.textInputBar.text = ""
		self.controller?.textInputBar.updateViews(animated: true)
		
		switch self.conversationState {
		case .askingQuestions(_, currentData: _):
			submit(text: trimmedText)
		case .loading(resource: _):
			break
		case .new:
			break
		case .loaded(let conversation, let pendingMessagesOperation, _):
			guard case .object(let creator) = conversation.creator else {
				return
			}
			let messageViewModel = MessageViewModel(avatar: .url(creator.avatar),  contentText: trimmedText, isSender: true, replyState: .yetToSend)
			messagesDataContainer.pendingMessages.append(messageViewModel)
			pendingMessagesOperation.addToQueue(message: messageViewModel)
		}
	}
}


extension MessagesDataSource: MessageSentDelegate {
	
	func addMessage(message: Message, fromSelf: Bool) {
		guard self.messagesDataContainer.messages[message.id] == nil else {
			return
		}
		
		if fromSelf {
			self.messagesDataContainer.pendingMessages.removeFirst()
		}
		
		self.messagesDataContainer.messages[message.id] = message

		
		//if abs(self.controller?.scrollToBottomContentOffset ?? 0) > CGFloat(100) {
		//	return
		//}
	}
	
	func messageDidEnqueue(message: MessageViewModel) {
		
	}
	
	func messageSendingFailed(error: Error) {
		var message = messagesDataContainer.pendingMessages[0]
		message.replyState = .failed
		messagesDataContainer.pendingMessages[0] = message
//		self.controller?.tableNode.reloadRows(at: [IndexPath.init(row: messagesDataContainer.botMessages.count + messagesDataContainer.messages.count, section: 0)], with: .fade)
	}
	
	func messageDidStartSending(message: MessageViewModel, previousState: MessageStatus) {
		self.messagesDataContainer.pendingMessages[0] = message
//		self.controller?.tableNode.reloadRows(at: [IndexPath.init(row: messagesDataContainer.botMessages.count + messagesDataContainer.messages.count, section: 0)], with: .fade)
	}
}

