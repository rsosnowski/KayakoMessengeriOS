//
//  ALTextInputBar.swift
//  ALTextInputBar
//
//  Created by Alex Littlejohn on 2015/04/24.
//  Copyright (c) 2015 zero. All rights reserved.
//

import AsyncDisplayKit

public class ALTextInputBar: UIView, ALTextViewDelegate {
    
    public weak var delegate: ALTextInputBarDelegate?
    public weak var keyboardObserver: ALKeyboardObservingView?
	public weak var replyBoxDelegate: ReplyBoxDelegate?
    
    // If true, display a border around the text view
    public var showTextViewBorder = false {
        didSet {
            textViewBorderView.isHidden = !showTextViewBorder
        }
    }
	
	let sendButton = ASButtonNode()
	let attachmentButton = ASButtonNode()
	let marketingButton = ASButtonNode()
    
    // TextView border insets
    public var textViewBorderPadding: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    
    // TextView corner radius
    public var textViewCornerRadius: CGFloat = 0 {
        didSet {
            textViewBorderView.layer.cornerRadius = textViewCornerRadius
        }
    }
    
    // TextView border width
    public var textViewBorderWidth: CGFloat = 2.0 {
        didSet {
            textViewBorderView.layer.borderWidth = textViewBorderWidth
        }
    }
    
    // TextView border color
    public var textViewBorderColor = ColorPallete.primaryBorderColor {
        didSet {
            textViewBorderView.layer.borderColor = textViewBorderColor.cgColor
        }
    }
    
    // TextView background color
    public var textViewBackgroundColor = UIColor.white {
        didSet {
            textView.backgroundColor = textViewBackgroundColor
        }
    }
    
    /// Used for the intrinsic content size for autolayout
    public var defaultHeight: CGFloat = 75
    
    /// If true the right button will always be visible else it will only show when there is text in the text view
    public var alwaysShowRightButton = false
    
    /// The horizontal padding between the view edges and its subviews
    public var horizontalPadding: CGFloat = 9
    
    /// The horizontal spacing between subviews
    public var horizontalSpacing: CGFloat = 5
    
    /// Convenience set and retrieve the text view text
    public var text: String! {
        get {
            return textView.text
        }
        set(newValue) {
            textView.text = newValue
            textView.delegate?.textViewDidChange?(textView)
        }
    }
    
    /** 
    This view will be displayed on the left of the text view.
    
    If this view is nil nothing will be displayed, and the text view will fill the space
    */
    public var leftView: UIView? {
        willSet(newValue) {
            if let view = leftView {
                view.removeFromSuperview()
            }
        }
        didSet {
            if let view = leftView {
                addSubview(view)
            }
        }
    }
    
    /**
    This view will be displayed on the right of the text view.
    
    If this view is nil nothing will be displayed, and the text view will fill the space
    If alwaysShowRightButton is false this view will animate in from the right when the text view has content
    */
    public var rightView: UIView? {
        willSet(newValue) {
            if let view = rightView {
                view.removeFromSuperview()
            }
        }
        didSet {
            if let view = rightView {
                addSubview(view)
            }
        }
    }
    
    /// The text view instance
    public let textView: ALTextView = {
        
        let _textView = ALTextView()
		_textView.clipsToBounds = true
        _textView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        _textView.textContainer.lineFragmentPadding = 0
        
        _textView.maxNumberOfLines = defaultNumberOfLines()
        
		if let color = KayakoLightStyle.MessageAttributes.placeholderAttrs[NSForegroundColorAttributeName] as? UIColor {
			_textView.placeholderColor = color
		}
        
        _textView.font = UIFont.systemFont(ofSize: FontSize.callout, weight: UIFontWeightRegular)
        _textView.textColor = UIColor.darkGray

        _textView.backgroundColor = .clear
        
        // This changes the caret color
        _textView.tintColor = ColorPallete.primaryBrandingColor
        
        return _textView
    }()
    
    private var showRightButton = false
    private var showLeftButton = false
    
    private var textViewBorderView: UIView!
        
    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
		let blur = UIBlurEffect(style: .extraLight)
		let blurView = UIVisualEffectView.init(effect: blur)
		blurView.backgroundColor = .clear
		
//		addSubview(blurView)
		blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        textViewBorderView = createBorderView()
		
        addSubview(textViewBorderView)
        addSubview(textView)
		
		sendButton.backgroundColor = ColorPallete.primaryBrandingColor
		sendButton.layer.cornerRadius = 13.0
		sendButton.alpha = 0.8
		sendButton.shadowColor = ColorPallete.primaryTextColor.cgColor
		sendButton.shadowOffset = CGSize(width: 0, height: 1)
		sendButton.shadowRadius = 3
		sendButton.shadowOpacity = 0.09
		
		sendButton.setImage(KayakoResources.sendButton.image, for: .normal)
		//HACK because the send button icon isn't centered
		sendButton.contentEdgeInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: -3)
		sendButton.addTarget(self, action: #selector(sendTapped), forControlEvents: .touchUpInside)
		addSubnode(sendButton)
		
		attachmentButton.setImage(KayakoResources.attachmentButton.image, for: .normal)
		attachmentButton.imageNode.contentMode = .scaleAspectFit
		attachmentButton.addTarget(self, action: #selector(self.attachmentTapped), forControlEvents: .touchUpInside)
		addSubnode(attachmentButton)
        
        textViewBorderView.isHidden = !showTextViewBorder
        textView.textViewDelegate = self
		
		let attributedMarketingString = NSMutableAttributedString(string: Bool.random() ? "Live Chat by Kayako" : "Messenger by Kayako")
		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.alignment = .right
		attributedMarketingString.setAttributes([NSParagraphStyleAttributeName: paragraphStyle], range: NSRange.init(location: 0, length: attributedMarketingString.string.characters.count))
		attributedMarketingString.setAttributes(KayakoLightStyle.ReplyBoxAttributes.marketingStyle, range: NSRange.init(location: 0, length: attributedMarketingString.string.characters.count - 6))
		attributedMarketingString.setAttributes(KayakoLightStyle.ReplyBoxAttributes.marketingBoldStyle, range: NSRange.init(location: attributedMarketingString.string.characters.count - 6, length: 6))
		
		marketingButton.setAttributedTitle(attributedMarketingString, for: .normal)
		addSubnode(marketingButton)
		marketingButton.addTarget(self, action: #selector(marketingButtonTapped), forControlEvents: ASControlNodeEvent.touchUpInside)
		marketingButton.hitTestSlop = UIEdgeInsets.init(top: -9, left: -9, bottom: -9, right: -9)
		self.backgroundColor = textViewBackgroundColor
    }
	
	
	func marketingButtonTapped() {
		let appName = Bundle.main.infoDictionary?["CFBundleExecutable"] as? String
		if let url = URL(string: "https://www.kayako.com/?utm_source=kayako-mobile-testing.kayako.com&utm_medium=messenger&utm_content=messenger-by-kayako&utm_campaign=product_links&app_name=" + (appName ?? "")) {
			UIApplication.shared.openURL(url)
		}
	}
	
	func sendTapped() {
		replyBoxDelegate?.sendButtonTapped(with: text, textView: textView)
	}
	
	func attachmentTapped() {
		replyBoxDelegate?.attachmentButtonTapped()
	}
    
    private func createBorderView() -> UIView {
        let borderView = UIView()
        
        borderView.backgroundColor = textViewBackgroundColor
        borderView.layer.borderColor = textViewBorderColor.cgColor
        borderView.layer.borderWidth = textViewBorderWidth
        borderView.layer.cornerRadius = textViewCornerRadius
        
        
        return borderView
    }
    
    // MARK: - View positioning and layout -

    override public var intrinsicContentSize: CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: defaultHeight)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        let size = frame.size
        let height = floor(size.height)
        
        var leftViewSize = CGSize.zero
        var rightViewSize = CGSize.zero
        
        if let view = leftView {
            leftViewSize = view.bounds.size
            
            let leftViewX: CGFloat = horizontalPadding
            let leftViewVerticalPadding = (defaultHeight - leftViewSize.height) / 2
            let leftViewY: CGFloat = height - (leftViewSize.height + leftViewVerticalPadding)
            
            UIView.performWithoutAnimation {
                view.frame = CGRect(x: leftViewX, y: leftViewY, width: leftViewSize.width, height: leftViewSize.height)
            }
        }

        if let view = rightView {
            rightViewSize = view.bounds.size
            
            let rightViewVerticalPadding = (defaultHeight - rightViewSize.height) / 2
            var rightViewX = size.width
            let rightViewY = height - (rightViewSize.height + rightViewVerticalPadding)
            
            if showRightButton || alwaysShowRightButton {
                rightViewX -= (rightViewSize.width + horizontalPadding)
            }
            
            view.frame = CGRect(x: rightViewX, y: rightViewY, width: rightViewSize.width, height: rightViewSize.height)
        }
        
//        let textViewPadding = (defaultHeight - textView.minimumHeight) / 2
        var textViewX = horizontalPadding
        let textViewY = CGFloat(13)
        let textViewHeight = textView.expectedHeight
		var textViewWidth = {
			if let superViewWidth = superview?.frame.width, superViewWidth < size.width {
				return superViewWidth
			} else {
				return size.width
			}
		}() - (horizontalPadding + horizontalPadding)
        
        if showTextViewBorder {
            textViewX += textViewBorderPadding.left
            textViewWidth -= textViewBorderPadding.left + textViewBorderPadding.right
        }
        
        textView.frame = CGRect(x: textViewX, y: textViewY, width: textViewWidth - 26 - 6, height: textViewHeight)
		
		sendButton.frame = CGRect(x: self.frame.maxX - 26 - 9, y: textView.center.y - 13, width: 26, height: 26)
		sendButton.hitTestSlop = UIEdgeInsetsMake(-9, -9, -9, -9)
		
		attachmentButton.frame = CGRect(x: 9, y: textView.frame.maxY + 18 , width: 15, height: 15)
		attachmentButton.hitTestSlop = UIEdgeInsetsMake(-9, -9, -9, -9)
		
		marketingButton.frame = CGRect(x: self.frame.maxX - 130 - 9, y: attachmentButton.view.center.y - 7.5, width: 130, height: 15)
		
        textViewBorderView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: 1)
		textViewBorderView.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
    }
    
    public func updateViews(animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.2) {
                self.setNeedsLayout()
                self.layoutIfNeeded()
            }
            
        } else {
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    // MARK: - ALTextViewDelegate -
    
    public final func textViewHeightChanged(textView: ALTextView, newHeight: CGFloat) {
        
        let padding = defaultHeight - textView.minimumHeight
        let height = padding + newHeight
        
        for constraint in constraints {
            if constraint.firstAttribute == NSLayoutAttribute.height && constraint.firstItem as! NSObject == self {
                constraint.constant = height < defaultHeight ? defaultHeight : height
            }
        }

        frame.size.height = height
        
        if let ko = keyboardObserver {
            ko.updateHeight(height: height)
        }
        
        if let d = delegate, let m = d.inputBarDidChangeHeight {
            m(height)
        }

        textView.frame.size.height = newHeight
    }
    
    public final func textViewDidChange(_ textView: UITextView) {
        
        self.textView.textViewDidChange()

        let shouldShowButton = textView.text.characters.count > 0
        
        if showRightButton != shouldShowButton && !alwaysShowRightButton {
            showRightButton = shouldShowButton
            updateViews(animated: true)
        }

		if text.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
			self.sendButton.alpha = 0.5
		} else {
			self.sendButton.alpha = 1.0
		}
        
        if let d = delegate, let m = d.textViewDidChange {
            m(self.textView)
        }
    }
    
    public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        var beginEditing: Bool = true
        if let d = delegate, let m = d.textViewShouldEndEditing {
            beginEditing = m(self.textView)
        }
        return beginEditing
    }
    
    public func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        var endEditing = true
        if let d = delegate, let m = d.textViewShouldEndEditing {
            endEditing = m(self.textView)
        }
        return endEditing
    }
    
    public func textViewDidBeginEditing(_ textView: UITextView) {
        if let d = delegate, let m = d.textViewDidBeginEditing {
            m(self.textView)
        }
    }
    
    public func textViewDidEndEditing(_ textView: UITextView) {
        if let d = delegate, let m = d.textViewDidEndEditing {
            m(self.textView)
        }
    }
    
    public func textViewDidChangeSelection(_ textView: UITextView) {
        if let d = delegate, let m = d.textViewDidChangeSelection {
            m(self.textView)
        }
    }
    
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        var shouldChange = true
        if let d = delegate, let m = d.textView {
            shouldChange = m(self.textView, range, text)
        }
        return shouldChange
    }
}

fileprivate extension Bool {
	static func random() -> Bool {
		return arc4random_uniform(2) == 0
	}
}
