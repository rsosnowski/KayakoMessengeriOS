//
//  MessageSendingOperations.swift
//  kayako-messenger-SDK
//
//  Created by Robin Malhotra on 07/04/17.
//  Copyright © 2017 Robin Malhotra. All rights reserved.
//
import Foundation

import UIKit

protocol MessageSentDelegate: class {
	func addMessage(message: Message, fromSelf: Bool)
	func messageSendingFailed(error: Error) -> ()
	func messageDidEnqueue(message: MessageViewModel) -> ()
	func messageDidStartSending(message: MessageViewModel, previousState: MessageStatus) -> ()
}

public class PendingMessagesOperations {
	var pendingMessages = Queue<MessageViewModel>()
	let client: Client
	let conversation: Conversation
	var currentlySendingClientID: String?
	var sentClientIDs = Set<String>()
	
	weak var delegate: MessageSentDelegate?
	
	init(client: Client, conversation: Conversation) {
		self.client = client
		self.conversation = conversation
	}
	
	func addToQueue(message: MessageViewModel) {
		pendingMessages.enqueue(message)
		delegate?.messageDidEnqueue(message: message)
		
		if let status = pendingMessages.front?.replyState,
			case .yetToSend = status {
			self.startSendingMessages()
		}
	}
	
	func KREMessageReceived(messageID: Int) {

		let messageResource = NetworkResource<Message>.id(parents: [("conversations", "\(conversation.id)")], id: messageID)
		
		self.client.load(resource: messageResource) { (result) in
			if case .success(let message) = result {
				
				guard let clientID = message.clientID else {
					self.delegate?.addMessage(message: message, fromSelf: false)
					return
				}
				
				let isFromSelf = (self.currentlySendingClientID == clientID)
				let isAlreadyProcessed = self.sentClientIDs.contains(clientID)
				
				guard !isAlreadyProcessed else {
					return
				}
				
				if isFromSelf {
					self.pendingMessages.dequeue()
					self.sentClientIDs.insert(clientID)
					self.startSendingMessages()
				} else {
					self.delegate?.addMessage(message: message, fromSelf: false)
				}
			}
		}
	}
	
	func startSendingMessages() {
		guard let message = pendingMessages.front else {
			return
		}
		
		//front is a get only property
		let prevState = pendingMessages.array[0].replyState
		pendingMessages.array[0].replyState = .sending
		delegate?.messageDidStartSending(message: pendingMessages.array[0], previousState: prevState)
		
		let uuidString = UUID().uuidString
		
		let attachment: AttachmentCreationModel? = {
			guard let type = message.attachments.first?.type,
				case .image(let thumbnail) = type,
				case .image(let image) = thumbnail,
				let jpgData = UIImageJPEGRepresentation(image, 0.1),
				let name = message.attachments.first?.name else { return nil }
			
			return AttachmentCreationModel(mimeType: "image/jpeg", data: jpgData, filename: name + ".jpeg")
		}()
		let messageCreateModel = MessageCreateModel(contents: message.contentText, sourceChannel: .MESSENGER, clientID: uuidString, file: attachment)
		self.currentlySendingClientID = uuidString
		let messageCreation = Creation<Message>.message(messageCreateModel, conversation.id)
		client.create(messageCreation) { (result) in
			switch result {
			case .success(let message):
				let isAlreadyProcessed = (self.sentClientIDs.contains(uuidString) == true)
				guard !isAlreadyProcessed else {
					return
				}
				self.pendingMessages.dequeue()
				self.delegate?.addMessage(message: message, fromSelf: true)
				if let clientID = message.clientID {
					self.sentClientIDs.insert(clientID)
				}
				self.startSendingMessages()
			case .failure(let error):
				self.pendingMessages.array[0].replyState = .failed
				self.delegate?.messageSendingFailed(error: error)
			}
		}
	}
}
