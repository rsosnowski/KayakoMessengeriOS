//
//  BotQuestionModel.swift
//  kayako-messenger-SDK
//
//  Created by Robin Malhotra on 07/03/17.
//  Copyright © 2017 Robin Malhotra. All rights reserved.
//

public enum BotMessage {
	case question(BotQuestionModel)
	case answer(String)
}

public struct BotQuestionModel {
	var type: BotQuestionType
	var state: BotQuestionState
	
	init(type: BotQuestionType, state: BotQuestionState) {
		self.type = type
		self.state = state
	}
}

enum BotQuestionType {
	case text(BotTextQuestion)
	case replyBoxInput(BotReplyQuestion)
//	case feedback(BotFeedback)
}

public enum BotQuestionState {
	case notAsked
	case failed
	case success
}

//MARK: - Bot question types

struct BotTextQuestion {
	let questionString: String
	let heading: String
	let placeholder: String
	var value: String
}

struct BotReplyQuestion {
	let questionString: String
}
