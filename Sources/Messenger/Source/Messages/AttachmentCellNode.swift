//
//  AttachmentCellNode.swift
//  kayako-messenger-SDK
//
//  Created by Robin Malhotra on 09/05/17.
//  Copyright © 2017 Robin Malhotra. All rights reserved.
//

import AsyncDisplayKit

import NVActivityIndicatorView

extension AttachmentMIMEType {
	public var icon: UIImage {
		return KayakoResources.file(self).image
	}
}

protocol AttachmentTapHandler: class {
	func attachmentWasTapped(sender: AttachmentCellNode)
}

class AttachmentCellNode: ASCellNode {
	
	var attachmentViewModel: AttachmentViewModel
	
	let thumbnailNode = ASNetworkImageNode()
	let headerNode = ASNetworkImageNode()
	let fileNameNode = ASTextNode()
	
	let client: Client?
	
	weak var delegate: AttachmentTapHandler?
	
	init(attachmentViewModel: AttachmentViewModel, client: Client? = nil) {
		self.attachmentViewModel = attachmentViewModel
		self.client = client
		super.init()
		
		self.addSubnode(headerNode)
		self.addSubnode(thumbnailNode)
		self.addSubnode(fileNameNode)
		
		load(attachmentViewModel: attachmentViewModel)
	}
	
	func load(attachmentViewModel: AttachmentViewModel) {
		self.attachmentViewModel = attachmentViewModel
		switch attachmentViewModel.type {
		case .file(let type):
			thumbnailNode.image = type.icon
		case .image(let thumbnail):
			switch thumbnail {
			case .url(let url):
				headerNode.url = client?.attachAuth(to: url)
			case .image(let image):
				headerNode.image = image
			}
		}
		
		let tapGR = UITapGestureRecognizer(target: self, action: #selector(tapped))
		self.view.addGestureRecognizer(tapGR)
		
		thumbnailNode.style.minWidth = ASDimensionMake(46)
		thumbnailNode.style.minHeight = ASDimensionMake(46)
		thumbnailNode.contentMode = .scaleAspectFit
	
		headerNode.style.height = ASDimensionMake(80)
		headerNode.style.width = ASDimensionMake(150)
		headerNode.backgroundColor = KayakoLightStyle.MessageAttributes.senderMessageBackgroundColor
		
		fileNameNode.style.width = ASDimensionMake(150)
		fileNameNode.attributedText = NSAttributedString(string: attachmentViewModel.name, attributes: KayakoLightStyle.AttachmentAttributes.fileNameStyle)
	}
	
	func tapped() {
		delegate?.attachmentWasTapped(sender: self)
		self.transitionLayout(withAnimation: true, shouldMeasureAsync: true, measurementCompletion: nil)
	}
	
	override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
		let insets = UIEdgeInsets(top: .infinity, left: .infinity, bottom: .infinity, right: .infinity)
		let thumbnailSpec = ASInsetLayoutSpec(insets: insets, child: thumbnailNode)
		let topHalf = ASOverlayLayoutSpec(child: headerNode, overlay: thumbnailSpec)
		
		let fileNameSpec = ASInsetLayoutSpec(insets: UIEdgeInsets.init(top: 9, left: 18, bottom: 9, right: 18), child: fileNameNode)
		
		return ASStackLayoutSpec(direction: .vertical, spacing: 0, justifyContent: .start, alignItems: .stretch, children: [topHalf, fileNameSpec])
	}
}
