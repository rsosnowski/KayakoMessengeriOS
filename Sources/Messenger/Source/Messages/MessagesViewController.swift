//
//  MessagesViewController.swift
//  kayako-messenger-SDK
//
//  Created by Robin Malhotra on 27/02/17.
//  Copyright © 2017 Robin Malhotra. All rights reserved.
//

import AsyncDisplayKit

import NVActivityIndicatorView

public enum HeaderData {
	case starterData(StarterData, Configuration)
	case agent(agent: UserMinimal, isOnline: Bool)
}

class MessagesViewController: UIViewController, UIGestureRecognizerDelegate, ALTextInputBarDelegate {
	
	var dataSource: MessagesDataSource
	let tableNode = ASTableNode()
	
	let textInputBar = ALTextInputBar()
	let keyboardObserver = ALKeyboardObservingView()
	
	let keyboardDelegate = ALKeyboardHandler()
	let separator = UIView()
	
	let unreadCounterView = UnreadCounterNode()
	
	enum HeaderState {
		case closed
		case open
	}
	
	let condensedAgentView = CondensedAgentView()
	let teamHeaderNode = TeamHeaderNode()
	let agentsHeaderNode = AgentsHeaderView()
	
	var headerState: HeaderState = .closed {
		didSet {
			switch headerState {
			case .closed:
				print("closed")
			case .open:
				print("opened")
			}
		}
	}
	let headerView = UIView()

	//MARK: Header stuff
	let loadingView: UIView = {
		let activityIndicator = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 56, height: 56), type: .ballClipRotate, color: ColorPallete.primaryBrandingColor, padding: 0.0)
		activityIndicator.startAnimating()
		return activityIndicator
	}()
	
	let configuration: Configuration
	let starterData: StarterData
	let client: Client
	
	static let stickyContentInsets = UIEdgeInsets(top: 18, left: 0, bottom: 0, right: 0)
	
	let scrollController = ScrollController()
	
	init(conversationState: ConversationState, configuration: Configuration, starterData: StarterData, client: Client = .shared) {
		self.dataSource = MessagesDataSource(conversationState: conversationState)
		self.configuration = configuration
		self.starterData = starterData
		self.client = client
		super.init(nibName: nil, bundle: nil)
		self.updateHeaders(with: .starterData(starterData, configuration))
		postDataSourceSetup()
	}

	
	init(resource: Resource<Conversation>, configuration: Configuration, starterData: StarterData, client: Client = .shared) {
		self.dataSource = MessagesDataSource(resource: resource)
		self.configuration = configuration
		self.starterData = starterData
		self.client = client
		super.init(nibName: nil, bundle: nil)
		self.updateHeaders(with: .starterData(starterData, configuration))
		postDataSourceSetup()
	}
	
	func postDataSourceSetup() {
		scrollController.scrollView = tableNode.view
		tableNode.view.separatorStyle = .none
		self.dataSource.controller = self
		self.tableNode.dataSource = dataSource
		self.tableNode.delegate = dataSource
	}

	func setHeaderAlphas(_ stickyHeaderHeight: CGFloat) {
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	let panGR = UIPanGestureRecognizer()
	
	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
		
		switch (gestureRecognizer, otherGestureRecognizer) {
		case (panGR, tableNode.view.panGestureRecognizer):
			fallthrough
		case (tableNode.view.panGestureRecognizer, panGR):
			return true
		default:
			return true
		}
	}
	
	func detect() {
//		let cells = tableNode.visibleNodes
//		for cell  in cells {
//			cell.view.transform = CGAffineTransform.init(translationX: panGR.translation(in: view).x, y: 0)
//		}
	}
	
	func updateHeaders(with data: HeaderData) {
		switch data {
		case .agent(let agent, let isOnline):
			let activityString: String = {
				let seconds = Date().timeIntervalSince(agent.lastActiveAt)
				
				if seconds > 5760 * 60 {
					return ""
				}
				if seconds > 1470 * 60 {
					let days = Int(floor(seconds/60/60/24))
					return "Active \(days) \(days == 1 ? "day": "days") ago"
				}
				if seconds > 1410 * 60 {
					return "Active in the last day"
				}
				if seconds > 90 * 60 {
					let hours = Int(floor(seconds/60/60))
					return "Active \(hours) \(hours == 1 ? "hour" : "hours") ago"
				}
				if seconds > 52 * 60 {
					return "Active in the last hour"
				}
				if seconds > 37 * 60 {
					return  "Active in the last 45 minutes"
				}
				if seconds > 15 * 60 {
					return  "Active in the last 30 minutes"
				}
				else {
					return "Active in the last 15 minutes"
				}
			}()
			self.textInputBar.textView.placeholder = "Reply to \(agent.firstName ?? agent.fullName)"
			condensedAgentView.load(CondensedAgentViewModel(agentAvatars: [(.url(agent.avatar), isOnline)]))
			teamHeaderNode.load(teamHeaderModel: TeamHeaderModel.init(brandName: agent.fullName, activity: activityString))
		case .starterData(let starterData, let config):
			let placeholderText: String = {
				switch dataSource.conversationState {
				case .new, .askingQuestions:
					return "Start a new conversation"
				case .loading, .loaded:
					return "Message \(config.brandName)"
				}
			}()
			self.textInputBar.textView.placeholder = placeholderText
			condensedAgentView.load(CondensedAgentViewModel(starterData))
			teamHeaderNode.load(teamHeaderModel: TeamHeaderModel(starterData, configuration))
		}
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.view.addSubnode(tableNode)
		self.view.addSubview(headerView)
		
		self.view.addSubnode(condensedAgentView)
		self.view.addSubnode(teamHeaderNode)
		self.view.addSubnode(agentsHeaderNode)
		
		panGR.addTarget(self, action: #selector(detect))
		panGR.delegate = self
		tableNode.view.addGestureRecognizer(panGR)
		
		separator.backgroundColor = UIColor.white.withAlphaComponent(0.15)
		self.view.addSubview(separator)
		self.view.addSubnode(self.unreadCounterView)
		
		self.navigationController?.navigationBar.tintColor = FlatColor.blue.colorValue
		
		tableNode.view.showsVerticalScrollIndicator = false
		tableNode.view.keyboardDismissMode = .interactive
		tableNode.contentInset = MessagesViewController.stickyContentInsets
		
		configureInputBar()
		makeNavBarTransparent()
		
		keyboardDelegate.controller = self
		NotificationCenter.default.addObserver(keyboardDelegate, selector: #selector(keyboardDelegate.keyboardFrameChanged(notification:)), name: NSNotification.Name(rawValue: ALKeyboardFrameDidChangeNotification), object: nil)
		NotificationCenter.default.addObserver(keyboardDelegate, selector: #selector(keyboardDelegate.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
		NotificationCenter.default.addObserver(keyboardDelegate, selector: #selector(keyboardDelegate.keyboardDidHide(notification:)), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
		NotificationCenter.default.addObserver(keyboardDelegate, selector: #selector(keyboardDelegate.keyboardDidShow(notification:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
		
		NotificationCenter.default.addObserver(forName: KayakoNotifications.unreadCountUpdated, object: nil, queue: .main) { [weak self] (notification) in
			self?.updateUnreadCounter()
		}
		
		updateUnreadCounter()
		
		if case .loaded = dataSource.conversationState,
			!dataSource.haveMessagesBeenLoaded {
			startLoading()
		}
		
		switch dataSource.conversationState {
		case .new, .askingQuestions:
			headerState = .open
		default:
			headerState = .closed
		}
    }
	
	func updateUnreadCounter() {
		guard case .loaded(let conversation, _, _) = dataSource.conversationState else {
			self.unreadCounterView.alpha = 0
			return
		}
		if ConversationsSource.shared.unreadCountTotal - (ConversationsSource.shared.conversations[conversation.id]?.unreadCount ?? 0) == 0 {
			self.unreadCounterView.alpha = 0
		} else {
			self.unreadCounterView.load(count: ConversationsSource.shared.unreadCountTotal - conversation.unreadCount)
			self.unreadCounterView.alpha = 1
		}
	}
	
	
	
	func configureInputBar() {
		
		keyboardObserver.isUserInteractionEnabled = false
		
		textInputBar.showTextViewBorder = true
		textInputBar.keyboardObserver = keyboardObserver
		textInputBar.replyBoxDelegate = dataSource
		textInputBar.delegate = self
		view.addSubview(textInputBar)
	}
	
	func makeNavBarTransparent() {
		// Change back bar button item
		self.navigationController?.navigationBar.topItem?.title = ""
		
		//TODO: change image later
//		self.navigationController?.navigationBar.backIndicatorImage = KayakoResources.backButton.image.resizableImage(withCapInsets: .zero)
//		self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = KayakoResources.backButton.image.resizableImage(withCapInsets: .zero)
		self.navigationController?.navigationBar.backItem?.title = ""
		self.navigationController?.navigationBar.tintColor = .white
		self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
		self.navigationController?.navigationBar.shadowImage = UIImage()
		
	}
	
	func setBackground(_ headerView: UIView) {
		
		headerView.layer.sublayers?.removeAll()
		switch configuration.background {
		case .flatColor(let color):
			headerView.backgroundColor = color
		case .customGradient(let colors):
			let gradient = CAGradientLayer.init()
			gradient.colors = colors.map{ $0.cgColor }
			gradient.frame = headerView.bounds
			gradient.startPoint = CGPoint.zero
			gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
			headerView.layer.insertSublayer(gradient, at: 0)
		case .image(let image):
			headerView.backgroundColor = UIColor(patternImage: image)
		case .patternColor(let pattern, let color):
			let layer = CALayer()
			let colorLayer = CALayer()
			colorLayer.backgroundColor = color.cgColor
			let patternLayer = CALayer()
			patternLayer.backgroundColor = UIColor(patternImage: pattern).cgColor
			layer.addSublayer(colorLayer)
			layer.addSublayer(patternLayer)
			headerView.layer.insertSublayer(layer, at: 0)
			layer.frame = headerView.bounds
			colorLayer.frame = layer.bounds
			patternLayer.frame = layer.bounds
		case .patternGradient(let pattern, let colors):
			let layer = CALayer()
			let gradient = CAGradientLayer.init()
			gradient.colors = colors.map{ $0.cgColor }
			let patternLayer = CALayer()
			patternLayer.backgroundColor = UIColor(patternImage: pattern).cgColor
			layer.addSublayer(gradient)
			layer.addSublayer(patternLayer)
			headerView.layer.insertSublayer(layer, at: 0)
			layer.frame = headerView.bounds
			gradient.frame = layer.bounds
			patternLayer.frame = layer.bounds
		}
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		makeNavBarTransparent()
		
		if !self.textInputBar.textView.isFirstResponder,
			dataSource.haveMessagesBeenLoaded {
			self.becomeFirstResponder()
		}


//: Code that removes and brings back the reply box
//		let deadline = DispatchTime.now() + .seconds(3)
//		DispatchQueue.main.asyncAfter(deadline: deadline) { 
//			self.resignFirstResponder()
//			let deadline = DispatchTime.now() + .seconds(3)
//			DispatchQueue.main.asyncAfter(deadline: deadline) {
//				self.becomeFirstResponder()
//			}
//		}
	}
	
	func startLoading() {
		self.resignFirstResponder()
		self.tableNode.alpha = 0
		self.view.backgroundColor = UIColor.white
		self.view.addSubview(loadingView)
		self.view.setNeedsLayout()
		self.textInputBar.alpha = 0
	}
	
	func stopLoading() {
		self.tableNode.alpha = 1
		self.loadingView.removeFromSuperview()
		self.becomeFirstResponder()
		self.view.setNeedsLayout()
		self.textInputBar.alpha = 1
	}
	
	override func viewDidLayoutSubviews() {
		headerView.frame = navigationController?.navigationBar.frame ?? .zero
		headerView.setBackground(background: configuration.background)
		
		
		condensedAgentView.frame = CGRect(x: view.frame.width - 62 - 18, y: 0, width: 62, height: 44)
		teamHeaderNode.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 44)

		separator.frame = CGRect(x: 5, y: self.navigationController?.navigationBar.frame.height ?? 44, width: view.frame.width - 10, height: 1)
		tableNode.frame = view.frame
		
		let navBarViews: (CGRect, CGRect) = {
			var dict: [CGFloat: UIView] = [:]
			for view in navigationController?.navigationBar.subviews ?? [] {
				if let otherView = dict[view.frame.minX] {
					return (view.frame.maxX > otherView.frame.maxX) ? (otherView.frame, view.frame) : (view.frame, otherView.frame)
				} else {
					dict[view.frame.minX] = view
				}
			}
			return (.zero, .zero)
		}()
		
		
		loadingView.frame = CGRect(x: view.frame.width/2 - 56/2, y: view.frame.height/2 - 56/2, width: 56, height: 56)
		
		unreadCounterView.frame = CGRect(x: navBarViews.0.maxX + 8, y: (navigationController?.navigationBar.frame.height ?? 0)/2 - 9, width: 24, height: 18)
	}
	
	override var inputAccessoryView: UIView? {
		get {
			return keyboardObserver
		}
	}
	
	override var canBecomeFirstResponder: Bool {
		return true
	}
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
}
