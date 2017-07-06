//
//  AttachmentMIMEType.swift
//  kayako-messenger-SDK
//
//  Created by Robin Malhotra on 04/05/17.
//  Copyright © 2017 Robin Malhotra. All rights reserved.
//


import Foundation

public enum AttachmentMIMEType {
	case image(thumnbnail: URL)
	case txt
	case html
	case css
	case pdf
	case doc
	case excel
	case ppt
	case adobe(AdobeType)
	case sketch
	case zip
	case audio
	case video
	case other
	
	public enum AdobeType {
		case photoshop
		case illustrator
		case xd
	}
	
	init(MIMEType: String, extension: String?) {
		let types = MIMEType.components(separatedBy: "/")
		if let type = types.first?.lowercased() {
			switch type {
			case "audio":
				self = .audio
				return
			case "video":
				self = .video
				return
			case "text":
				self = .txt
				return
			default:
				break
			}
		}
		
		if let subtype = types.last?.lowercased() {
			if subtype.contains("spreadsheet") {
				self = .excel
				return
			}
			if subtype.contains("presentation") {
				self = .ppt
				return
			}
			if subtype.contains("document") {
				self = .doc
				return
			}
			if subtype.contains("compressed") {
				self = .zip
				return
			}
		}
		
		if let `extension` = `extension` {
			switch `extension` {
			case "html":
				self = .html
				return
			case "css":
				self = .css
				return
			case "pdf":
				self = .pdf
				return
			case "sketch":
				self = .sketch
				return
			case "psd":
				self = .adobe(.photoshop)
				return
			case "ai":
				self = .adobe(.illustrator)
				return
			case "xd":
				self = .adobe(.xd)
				return
			default:
				break
			}
		}
		
		self = .other

	}
}

fileprivate extension String {
	func subString(startIndex: Int, endIndex: Int) -> String {
		guard endIndex > startIndex else {
			fatalError("End index of slice cannot be less than Start Index")
		}
		
		let range = Range(uncheckedBounds: (self.index(self.startIndex, offsetBy: startIndex), self.index(self.startIndex, offsetBy: endIndex)))
		return self.substring(with: range)
	}
}
