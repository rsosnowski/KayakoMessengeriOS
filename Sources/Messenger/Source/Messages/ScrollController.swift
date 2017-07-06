//
//  ScrollController.swift
//  kayako-messenger-SDK
//
//  Created by Robin Malhotra on 20/04/17.
//  Copyright © 2017 Robin Malhotra. All rights reserved.
//

import UIKit

private var ContentOffsetKVO = 0
private var ContentSizeKVO = 0

public class ScrollController: NSObject {
	
	var latestContentSize = CGFloat(0)
	
	public var scrollView: UIScrollView? {
		didSet {
			if let view = oldValue {
				removeKVO(view)
			}
			
			if let view = scrollView {
				addKVO(view)
				updateScrollPosition()
			}
		}
	}
	
	deinit {
		if let scrollView = scrollView {
			removeKVO(scrollView)
		}
	}
	
	private func removeKVO(_ scrollView: UIScrollView) {
		
		scrollView.removeObserver(
			self,
			forKeyPath: "contentSize",
			context: &ContentSizeKVO
		)
		
		scrollView.removeObserver(
			self,
			forKeyPath: "contentOffset",
			context: &ContentOffsetKVO
		)
	}
	
	private func addKVO(_ scrollView: UIScrollView) {
		
		scrollView.addObserver(
			self,
			forKeyPath: "contentSize",
			options: [.initial, .new],
			context: &ContentSizeKVO
		)
		
		scrollView.addObserver(
			self,
			forKeyPath: "contentOffset",
			options: [.initial, .new],
			context: &ContentOffsetKVO
		)
	}
	
	public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		switch keyPath {
		case .some("contentSize"), .some("contentOffset"):
			self.updateScrollPosition()
		default:
			super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
		}
	}
	
	private func updateScrollPosition() {
		self.latestContentSize = scrollView?.contentSize.height ?? 0
	}
}
