//
//  TestingViewController.swift
//  kayako-messenger-SDK
//
//  Created by Robin Malhotra on 19/05/17.
//  Copyright © 2017 Robin Malhotra. All rights reserved.
//


import AsyncDisplayKit

class TestingViewController: UIViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let node = BotFeedbackQuestionNode(feedback: nil)
		node.frame = CGRect(x: 0, y: 44, width: view.frame.width, height: 400)
		self.view.addSubnode(node)
	}
	
}
