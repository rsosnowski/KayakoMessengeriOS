//
//  MessagesDataContainer.swift
//  kayako-messenger-SDK
//
//  Created by Robin Malhotra on 07/04/17.
//  Copyright © 2017 Robin Malhotra. All rights reserved.
//

import UIKit


enum MessageData {
	case botMessage(BotMessage)
	case message(Message)
	case pendingMessage(MessageViewModel)
	case dateSeparator(Date)
	case feedback(BotFeedback)
	case messageStatus(MessageStatus, isSender: Bool)
	case typingIndicator(AvatarViewModel)
	
	func isOfSameType(as message: MessageData) -> Bool {
		switch (self, message) {
		case (.botMessage, .botMessage):
			return true
		case (.message, .message):
			return true
		case (.pendingMessage, .pendingMessage):
			return true
		case (.dateSeparator, .dateSeparator):
			return true
		case (.feedback, .feedback):
			return true
		case (.messageStatus, .messageStatus):
			return true
		case (.typingIndicator, .typingIndicator):
			return true
		default:
			break
		}
		return false
	}
}

enum MessageItemID {
	case message(id: Int)
	case dateSeparator(Date)
}

class MessagesDataContainer {
	
	weak var dataSource: MessagesDataSource?
	var conversationID: Int? {
		if let dataSource = self.dataSource,
			case .loaded(let conversation, _, _) = dataSource.conversationState {
			return conversation.id
		} else {
			return nil
		}
	}
	
	var botMessages: [BotMessage] = [] {
		didSet {
			self.updateMessagesData()
		}
	}
	
	var messages: [Int: Message] = [:] {
		didSet {
			self.updateMessagesData()
		}
	}
	
	var pendingMessages: [MessageViewModel] = [] {
		didSet {
			self.updateMessagesData()
		}
	}
	
	var typingIndicators: [AvatarViewModel] = [] {
		didSet {
			self.updateMessagesData()
		}
	}
	var botFeedback: BotFeedback? = nil {
		didSet {
			self.updateMessagesData()
		}
	}
	var statusIndex: Int?
	
	
	var messagesData: [MessageData] = []
	
	func updateMessagesData() {
		
		let messageDictKeys: [Int] = {
			var keys = self.messages.keys.sorted()
			if botMessages.count > 0,
				keys.count > 0 {
				keys.removeFirst()
			}
			return keys
		}()

		let messageItemIDs = messageDictKeys.enumerated().flatMap{ (index, id) -> [MessageItemID] in
			guard let message = self.messages[id] else {
				return []
			}
			if index > 0,
				let prevMessage = self.messages[messageDictKeys[index - 1]] {
				let calendar = Calendar(identifier: .iso8601)
				if calendar.compare(message.createdAt, to: prevMessage.createdAt, toGranularity: .day) != .orderedSame {
					return [.dateSeparator(message.createdAt), .message(id: message.id)]
				}
			}
			return [.message(id: message.id)]
		}
		
		self.statusIndex = {
			
			if self.pendingMessages.count > 0 {
				return botMessages.count + messageItemIDs.count + 1
			}
			
			if messageItemIDs.count > 0 {
				return botMessages.count + messageItemIDs.count
			}
			
			return {
				let lastAnswer = botMessages.enumerated().filter {
					switch $1 {
					case .answer(_):
						return true
					case .question(_):
						return false
					}
				}.last?.offset
				
				return lastAnswer.flatMap{ $0 + 1 }
			}()
		}()
		
		let oldMessagesData = self.messagesData
		let botFeedbackCount = (botFeedback == nil ? 0 : 1)
		let statusIndexCount = (statusIndex == nil ? 0 : 1)
		let count = botMessages.count + messageItemIDs.count + pendingMessages.count + typingIndicators.count + botFeedbackCount + statusIndexCount
		self.messagesData = (0..<count).map({ (index) -> MessageData in
			let position: Int = {
				if let statusIndex = statusIndex,
					index > statusIndex {
					return index - 1
				}
				return index
			}()
			
			let section1 = botMessages.count
			let section2 = botMessages.count + messageItemIDs.count
			
			if let statusIndex = statusIndex,
				index == statusIndex,
				statusIndex > 0 {
				let prevMessageIndex = self.index(before: statusIndex)
				switch prevMessageIndex {
				case 0..<section1:
					guard let state = dataSource?.conversationState else {
						return .messageStatus(.yetToSend, isSender: true)
					}
					switch state {
					case .askingQuestions(_, let currentData):
						if let _ = currentData["email"] {
							return .messageStatus(.sending, isSender: true)
						}
						return .messageStatus(.yetToSend, isSender: true)
					case .loaded(_, _, _):
						if let firstKey = self.messages.keys.sorted().first,
							let message = messages[firstKey] {
							return .messageStatus(message.status ?? .yetToSend , isSender: true)
						} else {
							return .messageStatus(.yetToSend, isSender: true)
						}
					default:
						return .messageStatus(.yetToSend, isSender: true)
					}
				case section1..<(section2):
					let index = prevMessageIndex - section1
					switch messageItemIDs[index] {
					case .dateSeparator(_):
						return .messageStatus(.sent, isSender: true)
					case .message(id: let id):
						if let message = messages[id] {
							if let dataSource = dataSource,
								case .loaded(let conversation, _, _) =  dataSource.conversationState,
								case .object(let conversationCreator) = conversation.creator,
								case .object(let messageCreator) = message.creator,
								messageCreator.id == conversationCreator.id {
								return .messageStatus(message.status ?? .sent, isSender: true)
							}
							let formatter = DateFormatter()
							formatter.dateStyle = .none
							formatter.timeStyle = .short
							return .messageStatus(.custom(formatter.string(from: message.createdAt)) , isSender: false)
						} else {
							fatalError("Message w/o valid ID")
						}
					}
				case (section2)..<count:
					if position == count - 1, let _ = botFeedback {
						return .messageStatus(.sent, isSender: true)
					} else {
						let index = prevMessageIndex - section2
						return .messageStatus(pendingMessages[index].replyState, isSender: true)
					}
				default:
					fatalError("Out of index array error")
				}
			}
			
			switch position {
			case 0..<section1:
				return .botMessage(botMessages[position])
			case section1..<(section2):
				let index = position - section1
				switch messageItemIDs[index] {
				case .dateSeparator(let date):
					return .dateSeparator(date)
				case .message(id: let id):
					if let message = messages[id] {
						return .message(message)
					} else {
						fatalError("Message w/o valid ID")
					}
				}
			case (section2)..<count:
				let index = position - section2
				if index < pendingMessages.count {
					return .pendingMessage(pendingMessages[index])
				} else {
					let index = position - section2 - pendingMessages.count
					if index < typingIndicators.count {
						return .typingIndicator(typingIndicators[index])
					} else if let feedback = botFeedback {
						return .feedback(feedback)
					}
				}
				fatalError("Out of index array error")
			default:
				fatalError("Out of index array error")
			}
		})
		
		var reloadIndices: [Int] = []
		
		let messagesDiff = oldMessagesData.diff(other: messagesData) { (message1, message2) -> Bool in
			if message1.isOfSameType(as: message2) {
				switch (message1, message2) {
				case (.botMessage(let botMessage1), .botMessage(let botMessage2)):
					switch (botMessage1, botMessage2) {
					case (.answer(let answer1), .answer(let answer2)):
						return answer1 == answer2
					case (.question(let question1), .question(let question2)):
						switch (question1.type, question2.type) {
						case (.text(let textQuestion1), .text(let textQuestion2)):
							if question1.state != question2.state,
								textQuestion1.questionString == textQuestion2.questionString {
								let reloadIndex = messagesData.index(where: { (message) -> Bool in
									if case .botMessage(let botMessage) = message,
										case .question(let question) = botMessage,
										case .replyBoxInput(let replyQuestion) = question.type {
										return replyQuestion.questionString == textQuestion1.questionString
									} else {
										return false
									}
								})
								if let reloadIndex = reloadIndex {
									reloadIndices.append(reloadIndex)
								}
							}
							return textQuestion1.questionString == textQuestion2.questionString
						case (.replyBoxInput(let replyQuestion1), .replyBoxInput(let replyQuestion2)):
							return replyQuestion1.questionString == replyQuestion2.questionString
						default:
							return false
						}
					default:
						return false
					}
				case (.message(let message1), .message(let message2)):
					return message1.id == message2.id
				case (.pendingMessage(let message1), .pendingMessage(let message2)):
					return message1.contentText == message2.contentText
				case (.dateSeparator(let date1), .dateSeparator(let date2)):
					return date1.compare(date2) == .orderedSame
				case (.feedback, .feedback):
					return true
				case (.messageStatus(let status1, _), .messageStatus(let status2, _)):
					return status1.statusText == status2.statusText
				case(.typingIndicator(let avatar1), .typingIndicator(let avatar2)):
					switch (avatar1, avatar2) {
					case (.url(let url1), .url(let url2)):
						return url1 == url2
					case (.image(let image1), .image(let image2)):
						return image1 == image2
					default:
						return false
					}
				default:
					return false
				}
			} else {
				return false
			}
		}
	
		dataSource?.updateTable(with: messagesDiff)
		
	}
	
	public var count: Int {
		return self.messagesData.count
	}
}

extension MessagesDataContainer: BidirectionalCollection {
	
	subscript(position: Int) -> MessageData {
		return messagesData[position]
	}
	
	
	var startIndex: Int {
		return 0
	}
	
	var endIndex: Int {
		return count
	}
	
	func index(after i: Int) -> Int {
		return i + 1
	}
	
	func index(before i: Int) -> Int {
		return i - 1
	}
	
	func shouldDisplayAvatar(at index: Int, senderID: Int) -> Bool {
		if index <= startIndex {
			return true
		}
		let currentMessageData = self[index]
		let lastMessageData = self[self.index(before: index)]
		
		if case .message(let lastMessage) = lastMessageData,
			case .pendingMessage(_) = currentMessageData,
			case .object(let lastCreator) = lastMessage.creator {
			return lastCreator.id != senderID
		}
		
		if lastMessageData.isOfSameType(as: currentMessageData) {
			
			guard case let .message(lastMessage) = lastMessageData,
				case let .message(currentMessage) = currentMessageData else {
					return true
			}
			
			guard case let .object(currentCreator) = currentMessage.creator,
				case let .object(lastCreator) = lastMessage.creator else {
				return true
			}
			
			guard currentCreator.id == lastCreator.id else {
				return true
			}
			return false
		}
		return true
	}
}
