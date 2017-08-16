//
//  Client.swift
//  kayako-messenger-SDK
//
//  Created by Robin Malhotra on 07/02/17.
//  Copyright © 2017 Robin Malhotra. All rights reserved.
//

import Foundation
import Unbox

public class Client {
	let session: URLSession
	let API: KayakoAPI
	
	static let boundary = String(format: "net.3lvis.networking.%08x%08x", arc4random(), arc4random())
	
	public static var shared = Client(baseURL: "kayako.com", auth: .fingerprints(fingerprintID: "", userInfo: nil))
	
	init(baseURL: String, session: URLSession, auth: Authorization) {
		self.session = session
		self.API = KayakoAPI(router: Router(baseURL: baseURL), auth: auth)
	}
	
	public init(baseURL: String, auth: Authorization) {
		self.session = URLSession(configuration: URLSessionConfiguration.default)
		self.API = KayakoAPI(router: Router(baseURL: baseURL), auth: auth)
	}
	
	public func attachAuth(to url: URL) -> URL? {
		var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
		switch API.auth {
		case .fingerprints(let fingerprintID, _):
			components?.queryItems = [URLQueryItem(name: "_fingerprint_id", value: fingerprintID)]
		case .session(let sessionID, _, _):
			components?.queryItems = [URLQueryItem(name: "_session_id", value: sessionID)]
		}
		
		return components?.url
	}
	
	@discardableResult public func loadArray<T>(resource: MultiResource<[T]>, completion: @escaping ((Result<[T]>) -> Void)) -> URLSessionDataTask where T: Unboxable {
		let request = API.loadArrayRequest(for: resource)
		let task = session.validatedDataTask(with: request) { (data, response, error) in
			DispatchQueue.main.sync {
				error.flatMap{ completion(Result.failure($0)) }
				
				do {
					let x: Result<[T]> = try Parser.shared.parseArray(data: data)
					completion(x)
					
				} catch {
					completion(Result.failure(error))
				}
			}
		}
		task.resume()
		return task
	}
	
	public func loadIfNecessary<T>(resources: [Resource<T>], resourceLoaded: @escaping ((Result<T>) -> Void), onAllResources: @escaping (([Result<T>]) -> Void) ) {
		let serviceGroup = DispatchGroup()
		
		var results: [Result<T>?] = resources.map{ _ in nil }
		
		for _ in resources { serviceGroup.enter() }
		
		for (index,resource) in resources.enumerated() {
			switch resource {
			case .notLoaded(let networkResource):
				load(resource: networkResource) { result in
					switch result {
					case .failure(let error):
						results[index] = .failure(error)
					case .success(let object):
						results[index] = .success(object)
					}
				}
			case .object(let object):
				results[index] = .success(object)
				serviceGroup.leave()
			}
		}
		serviceGroup.notify(queue: DispatchQueue.main) {
			let finalResults = results.flatMap{ $0 }
			if finalResults.count != resources.count {
				#if DEBUG
					fatalError("results is smaller than asked for")
				#endif
			}
			onAllResources(finalResults)
		}
	}
	
	@discardableResult public func load<T>(resource: NetworkResource<T>, include: [ResourceName]? = nil, completion: @escaping ((Result<T>) -> Void)) -> URLSessionTask where T: Unboxable {
		
		var request = include.flatMap{ API.loadRequest(for: resource, includeSet: $0) } ?? API.loadRequest(for: resource)
		request.cachePolicy = .reloadIgnoringLocalCacheData
		let task = session.validatedDataTask(with: request) { (data, response, error) in
			DispatchQueue.main.sync {
				error.flatMap{completion(Result.failure($0))}
				do {
					let x: Result<T> = try Parser.shared.parse(data: data)
					completion(x)
					
				} catch {
					completion(Result.failure(error))
				}
			}
		}
		task.resume()
		return task
	}
	
	@discardableResult public func create<T>(_ creation: Creation<T>, completion: @escaping ((Result<T>) -> Void)) -> URLSessionTask where T: Unboxable {
		let request = API.creationRequest(for: creation)
		let task = session.validatedDataTask(with: request) { (data, response, error) in
			DispatchQueue.main.sync {
				error.flatMap{ completion(Result.failure($0)) }
				do {
					let result: Result<T> = try Parser.shared.parse(data: data)
					completion(result)
				} catch {
					completion(Result.failure(error))
				}
			}
		}
		task.resume()
		return task
	}
	
	@discardableResult public func createConversation(with model: ConversationCreateModel, completion: @escaping ((Result<Conversation>) -> Void)) -> URLSessionTask {
		let creation = Creation<Conversation>.conversation(model)
		let task = create(creation) { (result) in
			completion(result)
		}
		return task
	}
	
	@discardableResult public func rateConversation(with model: RatingCreationModel, conversationID: Int, completion: @escaping ((Result<Rating>) -> Void)) -> URLSessionTask {
		let creation = Creation<Rating>.rating(model, conversationID)
		let task = create(creation) {
			(result) in
			completion(result)
		}
		return task
	}
	
	@discardableResult public func updateRating(for ratingID: Int, with model: RatingCreationModel, conversationID: Int, completion: @escaping ((Result<Rating>) -> Void)) -> URLSessionTask {
		let request = API.updateRequest(for: ratingID, with: model, conversationID: conversationID)
		let task = session.validatedDataTask(with: request) {
			(data, response, error) in
			DispatchQueue.main.sync {
				error.flatMap{ completion(Result.failure($0)) }
				do {
					let result: Result<Rating> = try Parser.shared.parse(data: data)
					completion(result)
				} catch {
					completion(Result.failure(error))
				}
			}
		}
		task.resume()
		return task
	}
	
	@discardableResult public func updateReadStatus(for messageID: Int, in conversationID: Int, completion: @escaping ((Result<Message>) -> Void)) -> URLSessionDataTask {
		let request = API.updateReadStatus(for: messageID, inConversation: conversationID)
		let task = session.validatedDataTask(with: request) { (data, response, error) in
			DispatchQueue.main.sync {
				error.flatMap{ completion(Result.failure($0)) }
				do {
					let result: Result<Message> = try Parser.shared.parse(data: data)
					completion(result)
				} catch {
					completion(Result.failure(error))
				}
			}
		}
		task.resume()
		return task
	}
	
	func authedURLForAttachment(url: URL) -> Result<URL> {
		return API.downloadRequest(for: url)
	}

}
