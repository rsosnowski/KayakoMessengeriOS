//
//  KayakoStyle.swift
//  kayako-messenger-SDK
//
//  Created by Robin Malhotra on 08/02/17.
//  Copyright © 2017 Robin Malhotra. All rights reserved.
//

import UIKit

enum FontSize {
	static var pageTitle = UIFont.preferredFont(forTextStyle: .title1).pointSize,// 28
		subTitle1 = UIFont.preferredFont(forTextStyle: .title2).pointSize,//22
		subtitle2 = UIFont.preferredFont(forTextStyle: .title3).pointSize,//20
		body = UIFont.preferredFont(forTextStyle: .body).pointSize,//17
		callout = UIFont.preferredFont(forTextStyle: .callout).pointSize,//16
		subHeading = UIFont.preferredFont(forTextStyle: .subheadline).pointSize,//15
		footnote = UIFont.preferredFont(forTextStyle: .footnote).pointSize, //13
		smallTitle = UIFont.preferredFont(forTextStyle: .caption2).pointSize //11
}

enum UIFontWeight {
	static let bold = UIFontWeightBold,
		semibold = UIFontWeightSemibold,
		regular = UIFontWeightRegular,
		light = UIFontWeightLight,
		heavy = UIFontWeightHeavy,
		black = UIFontWeightBlack,
		ultraLight = UIFontWeightUltraLight
}

public enum ColorPallete {
	static var
	linkColor = UIColor(red:0.33, green:0.69, blue:0.79, alpha:1.00),
	smallLinkColor = UIColor(red:0.25, green:0.65, blue:0.76, alpha:1.00),
	primaryTextColor = UIColor(red:0.18, green:0.19, blue:0.22, alpha:1.00),					//#2D3138
	secondaryTextColor = UIColor(red:0.37, green:0.42, blue:0.45, alpha:1.00),					//#5F6C73
	tertiaryTextColor = UIColor(red:0.51, green:0.55, blue:0.58, alpha:1.00),					//#838D94
	backgroundFillColor = UIColor(red:0.96, green:0.96, blue:0.96, alpha:1.00),					//#838D94
	secondaryBorderColor = UIColor(red:0.92, green:0.93, blue:0.94, alpha:1.00),
	primaryBorderColor = UIColor(red:0.82, green:0.84, blue:0.84, alpha:1.00),					//Zumthor or D1D5D7
	primaryBrandingColor = UIColor(red:0.95, green:0.44, blue:0.25, alpha:1.00),				//#F1703F
	placeholderTextColor = UIColor(red:0.63, green:0.67, blue:0.69, alpha:1.00),				//#A1AAAF
	secondaryFillColor = UIColor(red:0.97, green:0.97, blue:0.98, alpha:1.00),					//Black haze or #F7F8F9
	marketingTextColor = UIColor(red:0.73, green:0.75, blue:0.76, alpha:1.00),					//Silver Sand or #BCC0C2
	sentColor = UIColor(red:0.31, green:0.67, blue:0.37, alpha:1.00),							//Chateau Green or #4EAC5E
	primaryFailureColor = UIColor(red:0.86, green:0.25, blue:0.14, alpha:1.00),					//CG red or #DB3F24
	secondaryFailureColor = UIColor(red:0.95, green:0.44, blue:0.25, alpha:1.00),				//Orange or #F1703F
	failureBackgroundColor = UIColor(red:0.99, green:0.93, blue:0.93, alpha:1.00),				//Bridesmaid or #FCEEEC
	successBackgroundColor = UIColor(red:0.86, green:0.93, blue:0.87, alpha:1.00),				//Tara or #DCEEDF
	typingIndicatorColor = UIColor(red:0.44, green:0.45, blue:0.45, alpha:1.00),				//Rolling Stone or #717274
	white = UIColor.white
}

func stringAttributes(withSize size: CGFloat, weight: CGFloat, color: UIColor) -> [String: Any] {

	return [
		NSFontAttributeName: UIFont.systemFont(ofSize: size, weight: weight),
		NSForegroundColorAttributeName: color
	]
}

enum KayakoLightStyle {
	
	enum HomescreenAttributes {
		static let
		welcomeSubtitleStyle = stringAttributes(withSize: FontSize.callout, weight: UIFontWeight.regular, color: ColorPallete.white),
		nameStyle = stringAttributes(withSize: FontSize.subHeading, weight: UIFontWeight.semibold, color: ColorPallete.primaryTextColor),
		bodyStyle = stringAttributes(withSize: FontSize.subHeading, weight: UIFontWeight.regular, color: ColorPallete.primaryTextColor),
		widgetHeadingStyle = stringAttributes(withSize: FontSize.smallTitle, weight: UIFontWeight.bold, color: ColorPallete.primaryBrandingColor),
		widgetSubHeadingStyle = stringAttributes(withSize: FontSize.footnote, weight: UIFontWeight.regular, color: ColorPallete.primaryTextColor),
		lightSubtextStyle = stringAttributes(withSize: FontSize.footnote, weight: UIFontWeight.regular, color: ColorPallete.tertiaryTextColor),
		unreadIndicatorStyle = stringAttributes(withSize: 12, weight: UIFontWeight.bold, color: ColorPallete.white)
	}
	
	enum ConversationAttributes {
		static let
		nameStyle = stringAttributes(withSize: FontSize.callout, weight: UIFontWeight.semibold, color: ColorPallete.primaryTextColor),
		bodyStyle = stringAttributes(withSize: FontSize.callout, weight: UIFontWeight.regular, color: ColorPallete.secondaryTextColor),
		widgetHeadingStyle = stringAttributes(withSize: FontSize.footnote, weight: UIFontWeight.bold, color: ColorPallete.primaryBrandingColor),
		widgetSubHeadingStyle = stringAttributes(withSize: FontSize.footnote, weight: UIFontWeight.regular, color: ColorPallete.primaryTextColor),
		lightSubtextStyle = stringAttributes(withSize: FontSize.footnote, weight: UIFontWeight.regular, color: ColorPallete.tertiaryTextColor),
		conversationButtonStyle = stringAttributes(withSize: FontSize.subHeading, weight: UIFontWeight.semibold, color: .white)
	}
	
	enum MessageAttributes {
		static let
		darkBodyTextStyle = stringAttributes(withSize: FontSize.body, weight: UIFontWeight.regular, color: ColorPallete.primaryTextColor),
		emojiBodyTextStyle = stringAttributes(withSize: 44, weight: UIFontWeight.regular, color: ColorPallete.primaryTextColor),
		lightBodyTextStyle = stringAttributes(withSize: FontSize.body, weight: UIFontWeight.regular, color: ColorPallete.white),
		senderMessageBackgroundColor = UIColor(red:0.93, green:0.93, blue:0.94, alpha:1.00),
		inputBorderColor = UIColor(red:0.80, green:0.81, blue:0.82, alpha:1.00),
		inputBGColor = UIColor(red:0.98, green:0.98, blue:0.98, alpha:1.00),
		linkAttrs = stringAttributes(withSize: FontSize.body, weight: UIFontWeight.regular, color: UIColor(red:0.31, green:0.69, blue:0.80, alpha:1.00)),
		placeholderAttrs = [NSForegroundColorAttributeName: ColorPallete.placeholderTextColor, NSFontAttributeName: UIFont.systemFont(ofSize: 15, weight: UIFontWeightRegular)] as [String : Any]
	}
	
	enum BotMessageAttributes {
		static let
		headingStyle = stringAttributes(withSize: FontSize.smallTitle, weight: UIFontWeight.semibold, color: ColorPallete.secondaryTextColor),
		placeholderStyle = stringAttributes(withSize: FontSize.callout, weight: UIFontWeight.regular, color: ColorPallete.placeholderTextColor),
		textAnswerStyle = stringAttributes(withSize: FontSize.callout, weight: UIFontWeight.regular, color: ColorPallete.primaryTextColor),
		submitButtonStyle = stringAttributes(withSize: FontSize.callout, weight: UIFontWeight.semibold, color: ColorPallete.sentColor),
		successfulAnswerStyle = stringAttributes(withSize: FontSize.callout, weight: UIFontWeight.regular, color: ColorPallete.sentColor)
	}
	
	enum ReplyBoxAttributes {
		static let
		marketingStyle = stringAttributes(withSize: 12, weight: UIFontWeight.regular, color: ColorPallete.marketingTextColor),
		marketingBoldStyle = stringAttributes(withSize: 12, weight: UIFontWeight.semibold, color: ColorPallete.marketingTextColor)
	}
	
	enum MessageStatusAttributes {
		static let grayedOutStyle = stringAttributes(withSize: FontSize.footnote, weight: UIFontWeight.regular, color: ColorPallete.placeholderTextColor)
		static let seenStyle = stringAttributes(withSize: FontSize.footnote, weight: UIFontWeight.regular, color: ColorPallete.sentColor)
		static let errorStyle = stringAttributes(withSize: FontSize.footnote, weight: UIFontWeight.regular, color: ColorPallete.primaryFailureColor)
		static let typingIndicator = stringAttributes(withSize: FontSize.footnote, weight: UIFontWeight.regular, color: ColorPallete.typingIndicatorColor)
		static let typingIndicatorBold = stringAttributes(withSize: FontSize.footnote, weight: UIFontWeight.semibold, color: ColorPallete.typingIndicatorColor)
	}
	
	enum AttachmentAttributes {
		static let fileNameStyle = stringAttributes(withSize: FontSize.footnote, weight: UIFontWeight.semibold, color: ColorPallete.primaryTextColor)
	}
	
	enum MessageHeaderAttributes {
		static let teamStyle = stringAttributes(withSize: FontSize.subHeading, weight: UIFontWeight.semibold, color: ColorPallete.white)
		static let timeStyle = stringAttributes(withSize: FontSize.smallTitle, weight: UIFontWeight.regular, color: ColorPallete.white.withAlphaComponent(0.75))
		static let activityStyle = stringAttributes(withSize: FontSize.footnote + 1, weight: UIFontWeight.regular, color: ColorPallete.white)
	}
	
	enum FeedbackAttributes {
		static let headerStyle = stringAttributes(withSize: FontSize.smallTitle, weight: UIFontWeight.semibold, color: ColorPallete.tertiaryTextColor)
		static let feedbackStyle = stringAttributes(withSize: FontSize.callout, weight: UIFontWeight.regular, color: ColorPallete.primaryTextColor)
		static let feedbackPlaceholderStyle = stringAttributes(withSize: FontSize.callout, weight: UIFontWeight.regular, color: ColorPallete.placeholderTextColor)
		static let goodFeedbackSubmit = stringAttributes(withSize: FontSize.callout, weight: UIFontWeight.semibold, color: ColorPallete.sentColor)
		static let badFeedbackSubmit = stringAttributes(withSize: FontSize.callout, weight: UIFontWeight.semibold, color: ColorPallete.primaryFailureColor)
	}
	
	enum DateSeparatorAttributes {
		static let dateSeparatorTextStyle = stringAttributes(withSize: FontSize.footnote - 1, weight: UIFontWeight.regular, color: ColorPallete.placeholderTextColor)
	}
	
	static func applyDefaults() {
		UITextField.appearance().keyboardAppearance = .dark
		UINavigationBar.appearance().barStyle = .default
	}
	
}

