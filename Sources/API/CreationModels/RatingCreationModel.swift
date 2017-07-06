//
//  RatingCreationModel.swift
//  kayako-messenger-SDK
//
//  Created by Robin Malhotra on 19/05/17.
//  Copyright © 2017 Robin Malhotra. All rights reserved.
//

import Wrap

public struct RatingCreationModel: WrapCustomizable {
	public let feedback: BotFeedbackType
	public let comment: String?
	
	public func keyForWrapping(propertyNamed propertyName: String) -> String? {
		if propertyName == "feedback" {
			return "score"
		} else {
			return  propertyName
		}
	}
	
	public init(feedback: BotFeedbackType, comment: String?) {
		self.feedback = feedback
		self.comment = comment
	}
}
