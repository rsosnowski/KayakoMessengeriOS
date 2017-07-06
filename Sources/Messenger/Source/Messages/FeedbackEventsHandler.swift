//
//  FeedbackEventsHandler.swift
//  kayako-messenger-SDK
//
//  Created by Robin Malhotra on 19/05/17.
//  Copyright © 2017 Robin Malhotra. All rights reserved.
//

import Foundation


class FeedbackEventsHandler {
	let client: Client
	let conversationID: Int
	
	var ratingsRequest: URLSessionTask?
	var commentRequest: URLSessionTask?
	var state: State = .creatingRating
	
	enum State {
		case creatingRating
		case changingRating(Rating)
		case completed
	}
	
	init(client: Client, conversationID: Int) {
		self.client = client
		self.conversationID = conversationID
	}
	
	private func createRating(rating: RatingCreationModel) {
		if let request = ratingsRequest {
			print("🚨 Request cancelled")
			request.cancel()
		}
		
		self.ratingsRequest = client.rateConversation(with: rating, conversationID: conversationID) {
			result in
			self.ratingsRequest = nil
			switch result {
			case .success(let rating):
				self.state = .changingRating(rating)
			case .failure(let error):
				print(error)
			}
		}
	}
	
	private func updateRating(newRating: RatingCreationModel) {
		if let request = ratingsRequest {
			print("🚨 Request cancelled")
			request.cancel()
		}
		
		guard case .changingRating(let rating) = state else { return }
		
		client.updateRating(for: rating.id, with: newRating, conversationID: conversationID) {
			result in
			switch result {
			case .success(let rating):
				if rating.comment != nil {
					self.state = .completed
				} else {
					self.state = .changingRating(rating)
				}
			case .failure(let error):
				print(error)
			}
		}
	}
	
	func createOrUpdate(rating: RatingCreationModel) {
		switch self.state {
		case .creatingRating:
			createRating(rating: rating)
		case .changingRating(_):
			updateRating(newRating: rating)
		case .completed:
			break
		}
	}
	
}
