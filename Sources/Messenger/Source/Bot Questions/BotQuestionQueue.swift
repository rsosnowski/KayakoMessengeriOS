//
//  BotQuestionQueue.swift
//  kayako-messenger-SDK
//
//  Created by Robin Malhotra on 07/03/17.
//  Copyright © 2017 Robin Malhotra. All rights reserved.
//

import Foundation

enum BotQuestions {
	case auth
	case notAuth
	case empty
	
	func queue() -> Queue<BotQuestionModel> {
		switch self {
		case .notAuth:
			
			let subjectQuestionModel: BotQuestionModel = {
				let questionString = NSLocalizedString("askForSubject", tableName: "BotQuestions", bundle: KayakoResources.frameworkResourceBundle , comment: "Asking user for a subject")
				let question = BotReplyQuestion(questionString: questionString)
				return BotQuestionModel(type: .replyBoxInput(question), state: .notAsked)
			}()
			
			let emailQuestion: BotQuestionModel = {
				let questionString = NSLocalizedString("askForEmail", tableName: "BotQuestions", bundle: KayakoResources.frameworkResourceBundle, comment: "Asking user for email")
				let question = BotTextQuestion(questionString: questionString ,heading: "Your email", placeholder: "email", value: "")
				return BotQuestionModel(type: .text(question), state: .notAsked)
			}()
			
			return Queue<BotQuestionModel>.init(array: [subjectQuestionModel, emailQuestion])
		case .auth:
			let subjectQuestionModel: BotQuestionModel = {
				let questionString = NSLocalizedString("askForSubject", tableName: "BotQuestions", bundle: KayakoResources.frameworkResourceBundle, comment: "Asking user for a subject")
				let question = BotReplyQuestion(questionString: questionString)
				return BotQuestionModel(type: .replyBoxInput(question), state: .notAsked)
			}()
			return Queue<BotQuestionModel>.init(array: [subjectQuestionModel])
		case .empty:
			return Queue<BotQuestionModel>.init(array: [])
		}
	}

}
