//
//  Attachment.swift
//  kayako-messenger-SDK
//
//  Created by Robin Malhotra on 04/05/17.
//  Copyright © 2017 Robin Malhotra. All rights reserved.
//

import Foundation
import Unbox

public struct Attachment: Unboxable {
	public let url: URL
	public let name: String
	public let size: Int
	public let type: AttachmentMIMEType
	
	struct Thumbnail: Unboxable {
		let thumbURL: URL
		let size: Int
		
		init(unboxer: Unboxer) throws {
			self.thumbURL = try unboxer.unbox(key: "url")
			self.size = try unboxer.unbox(key: "size")
		}
	}
	
	public init(unboxer: Unboxer) throws {
		self.url = try unboxer.unbox(key: "url")
		let name: String = try unboxer.unbox(key: "name")
		self.name = name
		self.size = try unboxer.unbox(key: "size")
		
		if let thumbnails: [Thumbnail] = try? unboxer.unbox(key: "thumbnails"),
			let lastThumbnail = thumbnails.last {
			self.type = AttachmentMIMEType.image(thumnbnail: lastThumbnail.thumbURL)
		} else {
			self.type = AttachmentMIMEType(MIMEType: try unboxer.unbox(key: "type"), extension: name.components(separatedBy: ".").last)
		}
	
	}
}
