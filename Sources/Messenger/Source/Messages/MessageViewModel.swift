//
//  MessageViewModel.swift
//  kayako-messenger-SDK
//
//  Created by Robin Malhotra on 28/02/17.
//  Copyright © 2017 Robin Malhotra. All rights reserved.
//

import UIKit


public extension MessageStatus {
	var image: UIImage? {
		return KayakoResources.messageStatus(self).image
	}
}

public enum AvatarViewModel {
	case url(URL?)
	case image(UIImage)
}

public enum AttachmentTypeViewModel {
	case file(type: AttachmentMIMEType)
	case image(thumbnail: ThumbnailViewModel)
}

public enum ThumbnailViewModel {
	case image(UIImage)
	case url(URL)
}

public struct AttachmentViewModel {
	public let name: String
	public let type: AttachmentTypeViewModel
	public let downloadURL: URL?
	
	init(name: String, type: AttachmentTypeViewModel, downloadURL: URL?) {
		self.name = name
		self.type = type
		self.downloadURL = downloadURL
	}
}

extension Attachment {
	static func toViewModel(attachment: Attachment) -> AttachmentViewModel {
		let typeViewModel: AttachmentTypeViewModel = {
			switch attachment.type {
			case .image(let thumbnail):
				return AttachmentTypeViewModel.image(thumbnail: .url(thumbnail))
			default:
				return AttachmentTypeViewModel.file(type: attachment.type)
			}
		}()
		return AttachmentViewModel(name: attachment.name, type: typeViewModel, downloadURL: attachment.url)
	}
}

public struct MessageViewModel {
	
	public let avatar: AvatarViewModel
	public let attachments: [AttachmentViewModel]
	
	public let contentText: String
	public let isSender: Bool
	
	public var replyState: MessageStatus
	
	public mutating func fail() {
		self.replyState = .failed
	}
	
	init(avatar: AvatarViewModel, attachments: [AttachmentViewModel] = [], contentText: String, isSender: Bool, replyState: MessageStatus) {
		self.avatar = avatar
		self.attachments = attachments
		self.contentText = contentText
		self.isSender = isSender
		self.replyState = replyState
	}
}
