//
//  KREClient.swift
//  kayako-messenger-SDK
//
//  Created by Robin Malhotra on 22/03/17.
//  Copyright © 2017 Robin Malhotra. All rights reserved.
//

import Foundation

import Birdsong
import Unbox

public class KREClient {
	
	static var shared = KREClient(instance: "", auth: .fingerprints(fingerprintID: "", userInfo: nil))
	
	let instance: String
	let auth: Authorization
	let vsn = "1.0.0"
	
	let socket: Socket
	
	init(instance: String, auth: Authorization) {
		self.auth = auth
		self.instance = instance
		
		var components = URLComponents(string: "wss://kre.kayako.net/socket/websocket")
		let instanceQI = URLQueryItem(name: "instance", value: instance)
		let authQI: [URLQueryItem] = {
			switch auth {
			case .fingerprints(let fingerprintID, _):
				return [URLQueryItem.init(name: "fingerprint_id", value: fingerprintID)]
			case .session(let sessionID, let userAgent, _):
				return [URLQueryItem.init(name: "session_id", value: sessionID), URLQueryItem.init(name: "user_agent", value: userAgent)]
			}
		}()
		let versionQI = URLQueryItem.init(name: "vsn", value: vsn)
		components?.queryItems = [instanceQI, versionQI] + authQI
		
		if let url = components?.url {
			self.socket = Socket(url: url)
		} else {
			self.socket = Socket(url: "")
		}
		
		socket.enableLogging = false
	}
	
	func connect(onConnect: (@escaping () -> Void)) {
		socket.onConnect = onConnect
		socket.connect()
		socket.onDisconnect = {
			[weak self] error in
			self?.socket.connect()
		}
	}
	
	func addCallback(topic: String, event: String, closure: @escaping (Response) -> Void) {

		var channel: Channel
		
		if let subscribedChannel = socket.channels[topic] {
			channel = subscribedChannel
			channel.on(event, callback: closure)
		}
	}
	
	func addPresenceStateCallback(topic: String, onStateChange: @escaping ((Presence.PresenceState) -> Void)) {
		guard let channel = socket.channels[topic] else {
			return
		}
		// Presence support.
		channel.presence.onStateChange = onStateChange
	
		
		channel.onPresenceUpdate { (presence) in
			print(presence.firstMetas())
		}
		
		channel.presence.onJoin = { id, meta in
//			print("Join: user with id \(id) with meta entry: \(meta)")
		}
		
		channel.presence.onLeave = { id, meta in
//			print("Leave: user with id \(id) with meta entry: \(meta)")
		}
	}
	
	func addNewPostCallback(topic: String, closure: @escaping (_ postID: Int) -> Void) {
		self.addCallback(topic: topic, event: "NEW_POST") { (response) in
			do {
				let unboxer = Unboxer(dictionary: response.payload)
				let postID: Int = try unboxer.unbox(key: "resource_id")
				closure(postID)
			} catch {
				print("INVALID POST ID FOUND in message \(response.payload)")
			}
		}
	}
	
	func addChangeCallback(topic: String, closure: @escaping (Socket.Payload) -> Void) {
		self.addCallback(topic: topic, event: "CHANGE") { (response) in
			closure(response.payload)
		}
	}
	
	func addChangePostCallback(topic: String, closure: @escaping (Socket.Payload) -> Void) {
		self.addCallback(topic: topic, event: "CHANGE_POST") { (response) in
			closure(response.payload)
		}
	}
	
	func push(to topic: String, payload: Socket.Payload) {
		let channel = socket.channels[topic]
		channel?.send("update-presence-meta", payload: payload)
	}
	
	public func sendStartTypingEvent(to topic: String) {
		
		let payload: Socket.Payload = [
			"last_active_at": Date().timeIntervalSince1970,
			"is_typing": true
		]
		
		push(to: topic, payload: payload)
	}
	
	public func sendStopTypingEvent(to topic: String) {
		
		let payload: Socket.Payload = [
			"last_active_at": Date().timeIntervalSince1970,
			"is_typing": false
		]
		
		push(to: topic, payload: payload)
	}
}
