//
//  KayakoNotifications.swift
//  kayako-messenger-SDK
//
//  Created by Robin Malhotra on 01/06/17.
//  Copyright © 2017 Robin Malhotra. All rights reserved.
//

import Foundation

public enum KayakoNotifications {
	public static let top3Updated = NSNotification.Name("Kayako.Conversations.top3.updated")
	public static let conversationsUpdated = NSNotification.Name("Kayako.Conversations.updated")
	public static let conversationsInsertedOrDeleted = NSNotification.Name("Kayako.Conversations.insertedOrDeleted")
	public static let messagesUpdated = NSNotification.Name("Kayako.Messages.updated")
	public static let unreadCountUpdated = NSNotification.Name("Kayako.TotalUnreadCount.updated")
	public static let conversationTypingIndicator = NSNotification.Name("Kayako.Conversations.updateTypingAgents")
	public static let newPostReceieved = NSNotification.Name("Kayako.Conversations.newPostReceieved")
	public static let conversationCompleted = NSNotification.Name("Kayako.Conversations.conversationCompleted")
}
