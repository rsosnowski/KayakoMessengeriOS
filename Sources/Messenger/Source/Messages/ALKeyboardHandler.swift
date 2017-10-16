//
//  ALKeyboardHandler.swift
//  Kayako
//
//  Created by Robin Malhotra on 16/03/17.
//  Copyright © 2017 Kayako. All rights reserved.
//

import AsyncDisplayKit

class ALKeyboardHandler: NSObject {

	weak var controller: MessagesViewController?
	
	static let bottomPadding = CGFloat(9.0)
	
	func keyboardFrameChanged(notification: NSNotification) {
		if let userInfo = notification.userInfo {
			let frame = userInfo[UIKeyboardFrameEndUserInfoKey] as! CGRect
			
			guard let controller = controller else { return }
			controller.textInputBar.frame = CGRect(x: frame.origin.x, y: frame.origin.y - CardPresentationManager.cardOffset, width: controller.keyboardObserver.frame.size.width, height: controller.keyboardObserver.frame.size.height)
			setInsets(frame: frame)
		}
	}
	
	func setInsets(frame: CGRect) {
		guard let controller = controller else { return }
		let windowHeight = controller.view.window?.frame.height ?? 0
		controller.tableNode.contentInset.bottom = windowHeight - frame.origin.y + ALKeyboardHandler.bottomPadding
	}
	
	func setOffsets(frame: CGRect) {
		guard let controller = controller else { return }
		let viewportHeight = frame.origin.y - CardPresentationManager.cardOffset
		if controller.scrollController.latestContentSize > viewportHeight {
			controller.tableNode.contentOffset = CGPoint(x: 0, y: controller.scrollController.latestContentSize - controller.textInputBar.frame.origin.y  + ALKeyboardHandler.bottomPadding)
		}
	}
	
	func keyboardWillShow(notification: NSNotification) {
		guard let controller = controller,
			let userInfo = notification.userInfo,
			let frame = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect,
			frame.height > 75 else { return }
		
		let animationTime = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! TimeInterval
		let animationCurve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber
		
		UIView.animate(withDuration: animationTime, delay: 0.0, options: UIViewAnimationOptions(rawValue: UInt(animationCurve)), animations: {
			self.setInsets(frame: frame)
			self.setOffsets(frame: frame)
			controller.textInputBar.frame.origin.y = frame.origin.y - CardPresentationManager.cardOffset
			
		}, completion: nil)
	}
	
	func keyboardDidShow(notification: NSNotification) {
		
	}
	
	func keyboardDidHide(notification: NSNotification) {
		guard let controller = controller,
			let userInfo = notification.userInfo,
			let frame = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect,
			frame.height >= 75 else { return }
		
		let animationTime = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! TimeInterval
		let animationCurve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber
		
		UIView.animate(withDuration: animationTime, delay: 0.0, options: UIViewAnimationOptions(rawValue: UInt(animationCurve)), animations: {
			
			self.setInsets(frame: frame)
			controller.textInputBar.frame.origin.y = frame.origin.y - CardPresentationManager.cardOffset
			
		}, completion: nil)
	}
}

extension MessagesViewController {
	
	var isUserCloseToBottom: Bool {
		return true
	}
	
	var scrollToBottomContentOffset: CGFloat {
		return self.scrollController.latestContentSize - viewportHeight
	}
	
	var viewportHeight: CGFloat {
		return self.tableNode.frame.height - self.tableNode.contentInset.bottom
	}
	
	func scrollToBottom(additionalOffset: CGFloat = 0, force: Bool = false) {
		self.tableNode.waitUntilAllUpdatesAreProcessed()
		
		guard (force == true ? true : self.scrollController.latestContentSize + additionalOffset > viewportHeight) else {
			return
		}
		
		let rect = self.tableNode.rectForRow(at: IndexPath.init(row: self.dataSource.messagesDataContainer.messagesData.endIndex - 1, section: 0))
		self.scrollToOffset(offset: rect.maxY)

	}
	
	func scrollToOffset(offset: CGFloat) {
		UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseOut, animations: {
			self.tableNode.contentOffset = CGPoint(x: 0, y: offset - self.viewportHeight)
		}, completion: nil)

	}
}
