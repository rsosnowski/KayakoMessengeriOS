//
//  HomeScreenViewController.swift
//  kayako-messenger-SDK
//
//  Created by Robin Malhotra on 08/02/17.
//  Copyright © 2017 Robin Malhotra. All rights reserved.
//

import AsyncDisplayKit


class HomeScreenViewController: UIViewController, ASTableDelegate {
	
	let dataSource: HomeScreenDataSource
	var configuration: Configuration
	let newConversationButton = NewConversationButton()
	
	let node: ASDisplayNode
	let tableNode = ASTableNode(style: .plain)
	
	required init?(coder aDecoder: NSCoder) {
		self.node = ASDisplayNode()
		self.configuration = Configuration.placeholder
		self.dataSource = HomeScreenDataSource(client: Client.shared, configuration: self.configuration)
		super.init(coder: aDecoder)
	}
	
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		self.node = ASDisplayNode()
		self.configuration = Configuration.placeholder
		self.dataSource = HomeScreenDataSource(client: Client.shared, configuration: self.configuration)
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
	}
	
	init(configuration: Configuration) {
		self.node = ASDisplayNode()
		self.configuration = configuration
		self.dataSource = HomeScreenDataSource(client: Client.shared, configuration: self.configuration)
		super.init(nibName: nil, bundle: nil)
		dataSource.load()
	}

	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		tableNode.dataSource = dataSource
		tableNode.delegate = self
		dataSource.controller = self
		
		self.extendedLayoutIncludesOpaqueBars = true
		self.view.addSubnode(node)
		node.addSubnode(tableNode)
		node.frame = view.frame
		
		tableNode.view.separatorStyle = .none
		tableNode.view.tableFooterView = UIView()
		
		tableNode.dataSource = dataSource
		tableNode.backgroundColor = .clear
		
		tableNode.style.height = ASDimensionMakeWithFraction(1.0)
		tableNode.view.showsVerticalScrollIndicator = false
		
		tableNode.automaticallyManagesSubnodes = true
		

		view.addSubnode(newConversationButton)
		newConversationButton.addTarget(self, action: #selector(newConversationButtonTapped), forControlEvents: ASControlNodeEvent.touchUpInside)
		
		node.layoutSpecBlock = {
			[weak self] size in
			guard let tableNode = self?.tableNode else {
				return ASLayoutSpec()
			}
			let stack = ASStackLayoutSpec(direction: .vertical, spacing: 0.0, justifyContent: .start, alignItems: .stretch, children: [tableNode])
			return ASInsetLayoutSpec(insets: UIEdgeInsetsMake(18, 12, 0, 12), child: stack)
		}
		
		let barButtonItem = UIBarButtonItem(image: KayakoResources.closeButton.image, style: .plain, target: self, action: #selector(dismissVC))
		barButtonItem.tintColor = .white
		barButtonItem.width = 32.0
		self.navigationItem.rightBarButtonItems = [barButtonItem]

		self.node.view.setBackground(background: configuration.background)
		
    }
	
	func makeNavBarTransparent() {
		// Change back bar button item
		self.navigationController?.navigationBar.tintColor = .white
		self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
		self.navigationController?.navigationBar.shadowImage = UIImage()
		
		self.automaticallyAdjustsScrollViewInsets = false
	}

	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
	}
	
	
	func newConversationButtonTapped() {
		if case .loaded(let starterData) = dataSource.state {
			let messagesVC = MessagesViewController(conversationState: .new, configuration: configuration, starterData: starterData , client: dataSource.client)
			self.navigationController?.pushViewController(messagesVC, animated: true)
		}
	}
	
	
	override func viewWillAppear(_ animated: Bool) {
		self.makeNavBarTransparent()
	}
	
	func dismissVC() {
		self.dismiss(animated: true, completion: nil)
	}
	
	func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
		tableNode.deselectRow(at: indexPath, animated: true)
	}
	
	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		newConversationButton.frame = CGRect(x: (view.frame.width - 235)/2 , y: view.frame.height - 40 - 18, width: 235, height: 40)
		self.node.view.setBackground(background: configuration.background)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		node.frame = view.frame
	}
}
