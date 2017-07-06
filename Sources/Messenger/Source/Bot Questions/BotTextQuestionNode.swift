//
//  BotTextQuestionNode.swift
//  kayako-messenger-SDK
//
//  Created by Robin Malhotra on 07/03/17.
//  Copyright © 2017 Robin Malhotra. All rights reserved.
//

import AsyncDisplayKit

class BotTextQuestionNode: ASCellNode, ASEditableTextNodeDelegate {

	let headingNode = ASTextNode()
	let entryNode = ASEditableTextNode()
	let inputContainer = ASDisplayNode()
	let submitButton = ASButtonNode()

	let successfulEntry = ASTextNode()
	let successfulEntryContainer = ASDisplayNode()
	
	var state: BotQuestionState {
		didSet {
			transitionLayout(withAnimation: true, shouldMeasureAsync: true, measurementCompletion: nil)
		}
	}
	
	let messageNode: MessageCellNode
	
	weak var delegate: TextBarUpdateDelegate?
	weak var submitDelegate: InputSubmissionHandler?
	
	var question: BotTextQuestion {
		didSet {
			loadStyles()
		}
	}
	
	init(question: BotTextQuestion, state: BotQuestionState) {
		self.question = question
		let messageQuestionViewModel = MessageViewModel(avatar: .image(KayakoResources.kBot.image), contentText: question.questionString, isSender: false, replyState: .sent)
		self.messageNode = MessageCellNode(messageViewModel: messageQuestionViewModel)
		self.state = state
		
		super.init()
		
		self.addSubnode(messageNode)
		inputContainer.addSubnode(headingNode)
		inputContainer.addSubnode(entryNode)
		inputContainer.layoutSpecBlock = {
			_ in
			let stack = ASStackLayoutSpec(direction: .vertical, spacing: 10.0, justifyContent: .center, alignItems: .stretch, children: [self.headingNode, self.entryNode])
			return ASInsetLayoutSpec(insets: UIEdgeInsetsMake(21, 15, 21, 15), child: stack)
		}
		
		self.addSubnode(submitButton)
		submitButton.addTarget(self, action: #selector(submitButtonTapped), forControlEvents: .touchUpInside)
		
		self.addSubnode(successfulEntry)
		self.addSubnode(inputContainer)
		entryNode.delegate = self
		
		successfulEntryContainer.addSubnode(successfulEntry)
		self.addSubnode(successfulEntryContainer)
		successfulEntryContainer.layoutSpecBlock = {
			[weak self] size in
			guard let strongSelf = self else { return ASLayoutSpec() }
			let stack = ASStackLayoutSpec(direction: .horizontal, spacing: 0.0, justifyContent: .end, alignItems: .center, children: [strongSelf.successfulEntry])
			return ASInsetLayoutSpec(insets: UIEdgeInsets.init(top: 4, left: 4, bottom: 4, right: 18), child: stack)
		}
		loadStyles()
	}
	
	func editableTextNodeDidBeginEditing(_ editableTextNode: ASEditableTextNode) {
		delegate?.disableTextBar()
	}
	
	func editableTextNodeDidFinishEditing(_ editableTextNode: ASEditableTextNode) {
		delegate?.enableTextBar()
	}
	
	func editableTextNodeDidUpdateText(_ editableTextNode: ASEditableTextNode) {
//		self.question = BotTextQuestion(qheading: question.heading, placeholder: question.placeholder, value: editableTextNode.attributedText?.string ?? "")
	}
	
	func loadStyles() {
		
		let headingText: String = {
			switch self.state {
			case .success:
				return ""
			case .notAsked:
				return question.heading
			case .failed:
				return "Oops, email address seems invalid. Try again?"
			}
		}()
		
		let headingStyle: [String: Any] = {
			switch state {
			case .failed:
				var headingStyle = KayakoLightStyle.BotMessageAttributes.headingStyle
				headingStyle[NSForegroundColorAttributeName] = ColorPallete.primaryFailureColor
				return headingStyle
			default:
				return KayakoLightStyle.BotMessageAttributes.headingStyle
			}
		}()
		
		headingNode.attributedText = NSAttributedString(string: headingText, attributes: headingStyle)
		
		entryNode.attributedPlaceholderText = NSAttributedString(string: question.placeholder, attributes: KayakoLightStyle.BotMessageAttributes.placeholderStyle)
		entryNode.attributedText = NSAttributedString(string: question.value, attributes: KayakoLightStyle.BotMessageAttributes.textAnswerStyle)
		entryNode.typingAttributes = KayakoLightStyle.BotMessageAttributes.textAnswerStyle
		entryNode.maximumLinesToDisplay = 2
		
		submitButton.setAttributedTitle(NSAttributedString(string: "Submit", attributes: KayakoLightStyle.BotMessageAttributes.submitButtonStyle), for: [])
		submitButton.setBackgroundImage(UIImage.fromColor(color: .lightGray), for: .selected)
		submitButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
		
		self.successfulEntry.attributedText = NSAttributedString(string: question.value, attributes: KayakoLightStyle.BotMessageAttributes.successfulAnswerStyle)
		self.successfulEntry.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
		successfulEntryContainer.layer.cornerRadius = 4.0
		successfulEntryContainer.clipsToBounds = true
		successfulEntryContainer.backgroundColor = ColorPallete.successBackgroundColor
	}
	
	override func layoutDidFinish() {
		submitButtonMaskBorder()
		inputContainerMaskBorder()
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
		switch state {
		case .notAsked, .failed:
			borderLayer.strokeColor = ColorPallete.primaryBorderColor.cgColor
		case .success:
			borderLayer.strokeColor = ColorPallete.sentColor.cgColor
		}
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
		switch state {
		case .notAsked:
			borderLayer.strokeColor = ColorPallete.primaryBorderColor.cgColor
			borderLayer.fillColor = UIColor.clear.cgColor
		case .failed:
			borderLayer.strokeColor = ColorPallete.secondaryFailureColor.cgColor
			borderLayer.fillColor = ColorPallete.failureBackgroundColor.cgColor
		case .success:
			borderLayer.strokeColor = ColorPallete.sentColor.cgColor
		}
		inputContainer.layer.insertSublayer(borderLayer, at: 0)
	}
	
	func submitButtonTapped() {
		submitDelegate?.submit(text: entryNode.attributedText?.string ?? "")
	}
	
	override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
		switch state {
		case .notAsked, .failed:
			let inputAndSubmit = ASStackLayoutSpec(direction: .vertical, spacing: -1.0, justifyContent: .center, alignItems: .stretch, children: [inputContainer, submitButton])
			let inputInsetted = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 59, 15, 50), child: inputAndSubmit)
			let stack = ASStackLayoutSpec(direction: .vertical, spacing: 4, justifyContent: .start, alignItems: .stretch, children: [messageNode, inputInsetted])
			let insetted = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(21, 0, 0, 0), child: stack)
			return insetted
		case .success:
			let stack = ASStackLayoutSpec(direction: .horizontal, spacing: 0, justifyContent: .end, alignItems: .center, children: [successfulEntryContainer])
			successfulEntryContainer.style.spacingAfter = 18.0
			let insetted = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(4, 4, 4, 4), child: stack)
			return insetted
		}
	}
}
