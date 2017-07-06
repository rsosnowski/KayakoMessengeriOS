//
//  KayakoAPI.swift
//  kayako-messenger-SDK
//
//  Created by Robin Malhotra on 15/02/17.
//  Copyright © 2017 Robin Malhotra. All rights reserved.
//

import Foundation

struct KayakoAPI {
	
	let router: Router
	let auth: Authorization
	
	func loadRequest<T>(for resource: NetworkResource<T>, includeSet: [ResourceName] = [.minimalSet]) -> URLRequest {
		var request = URLRequest(url: router.url(for: resource, includes: replaceIfMinimalSet(in: includeSet, for: T.self)))
		request.httpMethod = RequestMethod.GET.rawValue
		
		if case .fingerprints(let fingerprintID, _) = auth {
			request.addValue(fingerprintID, forHTTPHeaderField: "X-Fingerprint-ID")
		}
		
		return request
	}
	
	func loadArrayRequest<T>(for resource: MultiResource<T>, includeSet: [ResourceName] = [.minimalSet]) -> URLRequest {
		var request = URLRequest(url: router.url(for: resource, includes: replaceIfMinimalSet(in: includeSet, for: T.self)))
		
		if case .fingerprints(let fingerprintID, _) = auth {
			request.addValue(fingerprintID, forHTTPHeaderField: "X-Fingerprint-ID")
		}
		
		request.httpMethod = RequestMethod.GET.rawValue
		return request
	}
	
	func replaceIfMinimalSet<T>(in includeSet: [ResourceName], for type: T.Type) -> [ResourceName] {
		var copyOfIncludeSet = includeSet
		if let index = includeSet.index(of: .minimalSet) {
			let minimalSet = ResourceName.minimal(for: T.self)
			copyOfIncludeSet.remove(at: index)
			return Array(Set(copyOfIncludeSet + minimalSet))
		} else {
			return copyOfIncludeSet
		}
	}
	
	func creationRequest<T>(for creation: Creation<T>, includeSet: [ResourceName] = [.minimalSet]) -> URLRequest  {
		let url = creation.url(router: router, includes: replaceIfMinimalSet(in: includeSet, for: T.self))
		var request = URLRequest(url: url)
		
		if case .fingerprints(let fingerprintID, _) = auth {
			request.addValue(fingerprintID, forHTTPHeaderField: "X-Fingerprint-ID")
		}
		if T.self is Message.Type {
			request.addValue("multipart/form-data; boundary=011000010111000001101001", forHTTPHeaderField: "content-type")
		}
		
		request.httpMethod = RequestMethod.POST.rawValue
		request.httpBody = creation.creationData
		
		return request
	}
	
	
	//: PGDD
	
	public func updateRequest(for ratingID: Int, with model: RatingCreationModel, conversationID: Int) -> URLRequest {
		var request = URLRequest(url: router.updateRatingURL(ratingID: ratingID, conversationID: conversationID))
		
		if case .fingerprints(let fingerprintID, _) = auth {
			request.addValue(fingerprintID, forHTTPHeaderField: "X-Fingerprint-ID")
		}
		
		request.httpMethod = RequestMethod.PUT.rawValue
		request.httpBody = objectToData(object: model)
		
		return request
	}
	
	public func updateReadStatus(for messageID: Int, inConversation conversationID: Int) -> URLRequest {
		var request = URLRequest(url: router.url(for: NetworkResource<Message>.id(parents: [("conversations", "\(conversationID)")], id: messageID), includes: [.minimalSet]))
		if case .fingerprints(let fingerprintID, _) = auth {
			request.addValue(fingerprintID, forHTTPHeaderField: "X-Fingerprint-ID")
		}
		
		request.httpMethod = RequestMethod.PUT.rawValue
		request.httpBody = (try? ["message_status": "SEEN"].urlEncodedString())?.data(using: .utf8)
		return request
	}
	
	public func downloadRequest(for url: URL) -> Result<URL> {
		var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
		
		if case .fingerprints(let fingerprintID, _) = auth {
		components?.queryItems = [URLQueryItem(name: "_fingerprint_id", value: fingerprintID)]
		}
		if let url = components?.url {
			return .success(url)
		} else {
			let error = NSError(domain: "com.kayako.customersuccess", code: 666, userInfo: ["data": "URL not constructed for download"])
			return .failure(error)
		}
	}
	
}
