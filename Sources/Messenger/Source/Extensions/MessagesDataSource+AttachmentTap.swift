//
//  MessagesDataSource+AttachmentTap.swift
//  kayako-messenger-SDK
//
//  Created by Robin Malhotra on 10/05/17.
//  Copyright © 2017 Robin Malhotra. All rights reserved.
//

import UIKit
import SafariServices

//extension MessagesDataSource: AttachmentTapHandler, UIDocumentInteractionControllerDelegate {
extension MessagesDataSource: AttachmentTapHandler {
	
	func attachmentWasTapped(sender: AttachmentCellNode) {
		guard let downloadURL = sender.attachmentViewModel.downloadURL,
			let url = client.attachAuth(to: downloadURL) else {
			return
		}
		let vc = SFSafariViewController(url: url)
		vc.transitioningDelegate = CardTransitioningDelegate()
		vc.modalPresentationStyle = .custom
		self.controller?.present(vc, animated: true, completion: nil)
	}
}
