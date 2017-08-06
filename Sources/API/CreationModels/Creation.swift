//
//  Creation.swift
//  kayako-messenger-SDK
//
//  Created by Robin Malhotra on 02/03/17.
//  Copyright © 2017 Robin Malhotra. All rights reserved.
//

import Foundation
import Wrap

enum CreationWrapError: Error {
	case utf8ConversionFailed
}

enum MultipartParam {
	case dict(name: String, value: String)
	case file(fileName: String, data: Data)
}

public enum Creation<T> {
	case conversation(ConversationCreateModel)
	case message(MessageCreateModel, Int)
	case rating(RatingCreationModel, Int)
	
	func url(router: Router, includes: [ResourceName] = [.minimalSet]) -> URL {
		return router.url(for: self, includes: includes)
	}
	
	var creationData: Data {
		switch self {
		case .conversation(let conversationCreateModel):
			return objectToData(object: conversationCreateModel)
		case .message(let messageCreation, _):
			
			let newDict = [
				"contents": messageCreation.contents,
				"source": messageCreation.sourceChannel.rawValue,
				"clientID": messageCreation.clientID
			]
			
			return createBody(parameters: newDict, boundary: "011000010111000001101001", file: messageCreation.file)
			
		case .rating(let ratingCreation, _):
			return objectToData(object: ratingCreation)
		}
	}
	
	func createBody(parameters: [String: String], boundary: String, file: AttachmentCreationModel?) -> Data {
		let body = NSMutableData()
		
		let boundaryPrefix = "--\(boundary)\r\n"
		
		for (key, value) in parameters {
			body.appendString(boundaryPrefix)
			body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
			body.appendString("\(value)\r\n")
		}
		
		body.appendString(boundaryPrefix)
		
		if let file = file {
			body.appendString("Content-Disposition: form-data; name=\"files[\(index)]\"; filename=\"\(file.filename)\"\r\n")
			body.appendString("Content-Type: \(file.mimeType)\r\n\r\n")
			body.append(file.data)
			body.appendString("\r\n")
			body.appendString("--".appending(boundary.appending("--")))
		}
		
		return body as Data
	}


}

extension NSMutableData {
	func appendString(_ string: String) {
		let data = string.data(using: String.Encoding.utf8, allowLossyConversion: false)
		append(data!)
	}
}
