//
//  BotFeedback.swift
//  kayako-messenger-SDK
//
//  Created by Robin Malhotra on 19/05/17.
//  Copyright © 2017 Robin Malhotra. All rights reserved.
//

import Foundation

public enum BotFeedbackType: String {
	case good
	case bad
	
	public enum FeedbackError: Error {
		case invalidFeedback
	}
	
	init(text: String) throws {
		switch text.lowercased() {
			case "good":
				self = .good
			case "bad":
				self = .bad
			default:
				throw FeedbackError.invalidFeedback
		}
	}
}

public struct BotFeedback {
	public let feedback: BotFeedbackType?
	public let feedbackText: String?
	
	public init(feedback: BotFeedbackType?, feedbackText: String?) {
		self.feedback = feedback
		self.feedbackText = feedbackText
	}
}
