//
//  LoadingIndicator.swift
//  kayako-messenger-SDK
//
//  Created by Robin Malhotra on 31/03/17.
//  Copyright © 2017 Robin Malhotra. All rights reserved.
//

import NVActivityIndicatorView
import AsyncDisplayKit

class LoadingIndicator: ASDisplayNode {
	
	let indicatorNode = ASDisplayNode { () -> UIView in
		let frame = CGRect(x: 0, y: 0, width: 30, height: 30)
		return NVActivityIndicatorView(frame: frame, type: NVActivityIndicatorType.lineSpinFadeLoader, color: ColorPallete.primaryBrandingColor, padding: 0)
	}
	
	override init() {
		super.init()
		self.backgroundColor = .white
		self.addSubnode(indicatorNode)
		indicatorNode.style.width = ASDimensionMake(30)
		indicatorNode.style.width = ASDimensionMake(30)
		(indicatorNode.view as? NVActivityIndicatorView)?.startAnimating()
		self.layoutSpecBlock = {
			size in
			return ASStackLayoutSpec(direction: .vertical, spacing: 0.0, justifyContent: .center, alignItems: .center, children: [self.indicatorNode])
		}
	}
}
