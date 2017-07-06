 //
//  BotFeedbackQuestionNode.swift
//  kayako-messenger-SDK
//
//  Created by Robin Malhotra on 16/04/17.
//  Copyright © 2017 Robin Malhotra. All rights reserved.
//

import AsyncDisplayKit


public enum BotSelectedState: String {
	case selected
	case deselected
}

class FeedbackInputNode: ASDisplayNode {
	let feedbackTextField = ASEditableTextNode()
	let titleNode = ASTextNode()
	let submitButton = ASButtonNode()
	let inputContainer = ASDisplayNode()
	weak var parent: BotFeedbackQuestionNode?
	
	override init() {
		super.init()
		
		titleNode.attributedText = NSAttributedString(string: "Feedback", attributes: KayakoLightStyle.FeedbackAttributes.headerStyle)
		feedbackTextField.typingAttributes = KayakoLightStyle.FeedbackAttributes.feedbackStyle
		feedbackTextField.attributedPlaceholderText = NSAttributedString(string: "Start typing here", attributes: KayakoLightStyle.FeedbackAttributes.feedbackPlaceholderStyle)
		
		feedbackTextField.style.minHeight = ASDimensionMake(70)
		
		inputContainer.addSubnode(titleNode)
		inputContainer.addSubnode(feedbackTextField)
		
		submitButton.setAttributedTitle(NSAttributedString(string: "Submit", attributes: KayakoLightStyle.BotMessageAttributes.submitButtonStyle), for: [])
		submitButton.setBackgroundImage(UIImage.fromColor(color: .lightGray), for: .selected)
		submitButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
		submitButton.addTarget(parent, action: #selector(BotFeedbackQuestionNode.feedbackSubmitted), forControlEvents: .touchUpInside)
		
		inputContainer.layoutSpecBlock = {
			[weak self] size in
			let stack = ASStackLayoutSpec(direction: .vertical, spacing: 10.0, justifyContent: .center, alignItems: .stretch, children: [self?.titleNode, self?.feedbackTextField].flatMap{ $0 })
			return ASInsetLayoutSpec(insets: UIEdgeInsetsMake(21, 15, 21, 15), child: stack)
		}
		
		self.backgroundColor = .white
		self.automaticallyManagesSubnodes = true
	}
	
	
	func submitButtonMaskBorder() {
		let path = UIBezierPath(roundedRect: submitButton.bounds,
		                        byRoundingCorners:[.bottomRight, .bottomLeft],
		                        cornerRadii: CGSize(width: 4, height: 4))
		let maskLayer = CAShapeLayer()
		maskLayer.path = path.cgPath
		submitButton.layer.mask = maskLayer
		
		let borderLayer = CAShapeLayer()
		borderLayer.lineWidth = 2.0
		borderLayer.path = path.cgPath
		borderLayer.fillColor = UIColor.clear.cgColor
		borderLayer.strokeColor = ColorPallete.primaryBorderColor.cgColor
		submitButton.layer.addSublayer(borderLayer)
	}
	
	func inputContainerMaskBorder() {
		let path = UIBezierPath(roundedRect: inputContainer.bounds,
		                        byRoundingCorners:[.topRight, .topLeft],
		                        cornerRadii: CGSize(width: 4, height:  4))
		let maskLayer = CAShapeLayer()
		maskLayer.path = path.cgPath
		inputContainer.layer.mask = maskLayer
		
		let borderLayer = CAShapeLayer()
		borderLayer.lineWidth = 2.0
		borderLayer.path = path.cgPath
		borderLayer.fillColor = UIColor.clear.cgColor
		borderLayer.strokeColor = ColorPallete.primaryBorderColor.cgColor
		inputContainer.layer.insertSublayer(borderLayer, at: 0)
	}
	
	override func layoutDidFinish() {
		super.layoutDidFinish()
		submitButtonMaskBorder()
		inputContainerMaskBorder()
	}
	
	override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
		let stack =  ASStackLayoutSpec(direction: .vertical, spacing: -1.0, justifyContent: .start, alignItems: .stretch, children: [inputContainer, submitButton])
		return ASInsetLayoutSpec(insets: UIEdgeInsets.init(top: 0, left: 59, bottom: 0, right: 18), child: stack)
	}
	
}

open class BotFeedbackSubmissionNode: ASDisplayNode {
	let feedbackImageNode = ASImageNode()
	let feedbackTextNode = ASTextNode()
	
	public init(_ botFeedback: BotFeedback) {
		super.init()
		feedbackImageNode.image = KayakoResources.blob(botFeedback.feedback ?? .good, .deselected).image
		var regularAttrs = KayakoLightStyle.BotMessageAttributes.textAnswerStyle
		regularAttrs[NSFontAttributeName] = UIFont.italicSystemFont(ofSize: FontSize.callout)
		feedbackTextNode.attributedText = NSAttributedString(string: "\"\(botFeedback.feedbackText ?? "")\"", attributes: regularAttrs)
		self.automaticallyManagesSubnodes = true
		
		self.layer.borderColor = ColorPallete.primaryBorderColor.cgColor
		self.layer.cornerRadius = 4.0
		self.layer.borderWidth = 1.0
	}
	
	open override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
		feedbackTextNode.style.flexShrink = 0.1
		let stack = ASStackLayoutSpec(direction: .horizontal, spacing: 21, justifyContent: .spaceBetween, alignItems: .start, children: [feedbackImageNode, feedbackTextNode])
		return ASInsetLayoutSpec(insets: UIEdgeInsets.init(top: 18, left: 18, bottom: 18, right: 18), child: stack)
	}
}

open class CongratulatoryNode: ASDisplayNode {
	let tickNode = ASImageNode()
	let textNode = ASTextNode()
	
	public override init() {
		super.init()
		self.tickNode.image = KayakoResources.successTick.image
		self.textNode.attributedText = NSAttributedString(string: "Feedback Sent", attributes: KayakoLightStyle.BotMessageAttributes.textAnswerStyle)
		self.backgroundColor = ColorPallete.successBackgroundColor
		self.automaticallyManagesSubnodes = true
	}
	
	open override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
		let stack = ASStackLayoutSpec(direction: .horizontal, spacing: 4.0, justifyContent: .spaceBetween, alignItems: .center, children: [tickNode, textNode])
		return ASInsetLayoutSpec(insets: UIEdgeInsets.init(top: 12, left: 18, bottom: 12, right: 18), child: stack)
	}
}

open class BotFeedbackQuestionNode: ASCellNode {
	
	let messageNode: MessageCellNode
	let feedbackNode = FeedbackInputNode()
	let congratulatoryNode = CongratulatoryNode()
	
	weak var eventHandler: FeedbackEventsHandler?
	
	enum State {
		case askingGoodOrBad
		case askingFeedback
		case submitted(BotFeedback, BotFeedbackSubmissionNode)
	}
	
	let segmentedControl = ASDisplayNode { () -> UIView in
		let segment = UISegmentedControl(frame: CGRect(x: 10, y: 60, width: 300, height: 100))
		segment.insertSegment(with: KayakoResources.blob(.bad, .deselected).image.withRenderingMode(.alwaysOriginal), at: 0, animated: false)
		segment.insertSegment(with: KayakoResources.blob(.good, .deselected).image.withRenderingMode(.alwaysOriginal), at: 0, animated: false)
		segment.tintColor = UIColor(red:0.82, green:0.84, blue:0.84, alpha:1.00)
		return segment
	}

	var state: State = .askingGoodOrBad
	
	init(feedback: BotFeedback?) {
		let questionString = "How did we do?"
		let messageViewModel = MessageViewModel(avatar: .image(KayakoResources.kBot.image), contentText: questionString, isSender: false, replyState: .sent)
		self.messageNode = MessageCellNode(messageViewModel: messageViewModel)
		
		super.init()
		
		if let feedback = feedback {
			load(feedback)
		}
		self.automaticallyManagesSubnodes = true
	}
	
	func load(_ feedback: BotFeedback) {
		segmentedControl.style.height = ASDimensionMake(100)
		(segmentedControl.view as? UISegmentedControl)?.addTarget(self, action: #selector(segmentTapped), for: UIControlEvents.valueChanged)
	}
	
	func segmentTapped() {
		guard let segment = segmentedControl.view as? UISegmentedControl else { return }
		if segment.selectedSegmentIndex == 0 {
			segment.tintColor = ColorPallete.sentColor
			segment.setImage(KayakoResources.blob(.good, .selected).image.withRenderingMode(.alwaysOriginal), forSegmentAt: 0)
			segment.setImage(KayakoResources.blob(.bad, .deselected).image.withRenderingMode(.alwaysOriginal), forSegmentAt: 1)
			self.feedbackNode.submitButton.setAttributedTitle(NSAttributedString(string: "Submit", attributes: KayakoLightStyle.FeedbackAttributes.goodFeedbackSubmit), for: [])
		}
		
		if segment.selectedSegmentIndex == 1 {
			segment.tintColor = ColorPallete.primaryFailureColor
			segment.setImage(KayakoResources.blob(.good, .deselected).image.withRenderingMode(.alwaysOriginal), forSegmentAt: 0)
			segment.setImage(KayakoResources.blob(.bad, .selected).image.withRenderingMode(.alwaysOriginal), forSegmentAt: 1)
			self.feedbackNode.submitButton.setAttributedTitle(NSAttributedString(string: "Submit", attributes: KayakoLightStyle.FeedbackAttributes.badFeedbackSubmit), for: [])
		}
		
		let feedback: BotFeedbackType = (segment.selectedSegmentIndex == 0) ? .good : .bad
		eventHandler?.createOrUpdate(rating: .init(feedback: feedback, comment: nil))
		if case .askingGoodOrBad = state {
			self.state = .askingFeedback
			transitionLayout(withAnimation: true, shouldMeasureAsync: true, measurementCompletion: nil)
		}
	}
	
	func feedbackSubmitted() {
		guard let segment = segmentedControl.view as? UISegmentedControl else { return }
		let feedbackType: BotFeedbackType = (segment.selectedSegmentIndex == 0) ? .good : .bad
		let feedbackText = feedbackNode.feedbackTextField.textView.text
		
		let feedbackResult = BotFeedback(feedback: feedbackType, feedbackText: feedbackText)
		let successfulNode = BotFeedbackSubmissionNode(feedbackResult)
		successfulNode.style.width = ASDimensionMake(300)
		self.state = .submitted(feedbackResult, successfulNode)
		transitionLayout(withAnimation: true, shouldMeasureAsync: true, measurementCompletion: nil)
		eventHandler?.createOrUpdate(rating: RatingCreationModel.init(feedback: feedbackType, comment: feedbackText))
	}
	
	override open func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
		let segmentInset = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 59, bottom: 0, right: 18), child: segmentedControl)
		switch state {
		case .askingGoodOrBad:
			return ASStackLayoutSpec(direction: .vertical, spacing: 9.0, justifyContent: .start, alignItems: .stretch, children: [messageNode, segmentInset])
		case .askingFeedback:
			return ASStackLayoutSpec(direction: .vertical, spacing: 9.0, justifyContent: .start, alignItems: .stretch, children: [messageNode, segmentInset, feedbackNode])
		case .submitted(_, let node):
			congratulatoryNode.style.width = ASDimensionMakeWithFraction(1.0)
			let stack = ASStackLayoutSpec(direction: .vertical, spacing: 4.0, justifyContent: .start, alignItems: .start, children: [node, congratulatoryNode])
			return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 4.0, left: 59, bottom: 0, right: 18), child: stack)
		}
	}
}
