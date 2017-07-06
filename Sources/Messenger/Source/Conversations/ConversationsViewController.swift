//
//  ConversationsViewController.swift
//  kayako-messenger-SDK
//
//  Created by Robin Malhotra on 19/02/17.
//  Copyright © 2017 Robin Malhotra. All rights reserved.
//

import AsyncDisplayKit

import StatefulViewController

enum VCState {
	case loading
	case empty
	case error
	case loaded
}

class ConversationsViewController: UIViewController, ASTableDelegate, StatefulViewController {

	let tableNode = ASTableNode()
	var dataSource: ConversationsDataSource?
	
	let newConversationButton = NewConversationButton()
	let state: VCState = .loading
	
	let starterData: StarterData
	let configuration: Configuration
	
	init(starterData: StarterData, configuration: Configuration) {
		self.starterData = starterData
		self.configuration = configuration
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		let dataSource = ConversationsDataSource()
		self.dataSource = dataSource
		tableNode.dataSource = dataSource
		dataSource.controller = self
		tableNode.delegate = self
		tableNode.view.tableFooterView = UIView()
		
		dataSource.load()
		
		self.extendedLayoutIncludesOpaqueBars = true
		
		loadingView = LoadingIndicator().view
		
		view.addSubnode(tableNode)
		view.addSubnode(newConversationButton)
		
		tableNode.view.separatorInset = UIEdgeInsets(top: 0, left: 26, bottom: 0, right: 0)
		
		newConversationButton.addTarget(self, action: #selector(newConversationButtonTapped), forControlEvents: ASControlNodeEvent.touchUpInside)
		
		setupNavBar()
    }
	
	func hasContent() -> Bool {
		return state != .loading
	}
	
	func newConversationButtonTapped() {
		 //: PGDD Fix later
		let messagesVC = MessagesViewController(conversationState: .new, configuration: configuration, starterData: starterData, client: .shared)
		self.navigationController?.pushViewController(messagesVC, animated: true)
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		setupInitialViewState()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		setupNavBar()
	}
	
	func dismissVC() {
		self.dismiss(animated: true, completion: nil)
	}

	func setupNavBar() {
		
		let headerView = UIView()
		headerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.navigationController?.navigationBar.frame.height ?? 0)
		headerView.setBackground(background: configuration.background)
		self.view.addSubview(headerView)
		
		self.navigationController?.navigationBar.tintColor = .white
		self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
		self.navigationController?.navigationBar.shadowImage = UIImage()
		//: For sticky header
		self.automaticallyAdjustsScrollViewInsets = true
		self.title = "Conversations"
		self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
	}
	
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
	
	func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
		let selectedID = ConversationsSource.shared.keys[indexPath.row]
		guard let conversation = ConversationsSource.shared.conversations[selectedID] else {return}
		//: PGDD Fix later
		let messagingVC = MessagesViewController(resource: .object(conversation), configuration: configuration, starterData: starterData, client: .shared)
		self.tableNode.deselectRow(at: indexPath, animated: true)
		self.navigationController?.pushViewController(messagingVC, animated: true)
	}
	
	override func viewDidLayoutSubviews() {
		tableNode.frame = view.frame
		newConversationButton.frame = CGRect(x: (view.frame.width - 235)/2 , y: view.frame.height - 40 - 18, width: 235, height: 40)
		setupNavBar()
	}
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
	}
}

extension UINavigationController {
	open override var childViewControllerForStatusBarStyle: UIViewController? {
		return visibleViewController
	}
}
