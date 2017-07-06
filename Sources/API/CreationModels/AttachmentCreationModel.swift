//
//  AttachmentCreationModel.swift
//  kayako-messenger-SDK
//
//  Created by Robin Malhotra on 11/05/17.
//  Copyright © 2017 Robin Malhotra. All rights reserved.
//

import Foundation

public struct AttachmentCreationModel {
	public let mimeType: String
	public let data: Data
	public let filename: String
	
	public init(mimeType: String, data: Data, filename: String) {
		self.mimeType = mimeType
		self.data = data
		self.filename = filename
	}
}
