//
//  BundleResources.swift
//  kayako-messenger-SDK
//
//  Created by Robin Malhotra on 14/05/17.
//  Copyright © 2017 Robin Malhotra. All rights reserved.
//

import UIKit


public enum KayakoResources {
	case newConversation
	case closeButton
	case sendButton
	case attachmentButton
	case kBot
	case successTick
	case backButton
	case messageStatus(MessageStatus)
	case background(BackgroundPattern, BackgroundTone)
	case file(AttachmentMIMEType)
	case blob(BotFeedbackType, BotSelectedState)
	
	public var image: UIImage {
		let imageFromBundle: UIImage? = {
			switch self {
			case .newConversation:
				return imageFromFramework(named: "New Conversation")
			case .closeButton:
				return imageFromFramework(named: "Close Button")
			case .sendButton:
				return imageFromFramework(named: "Send Button")
			case .attachmentButton:
				return imageFromFramework(named: "Attachment")
			case .kBot:
				return imageFromFramework(named: "K-Bot")
			case .successTick:
				return imageFromFramework(named: "Congrats Tick")
			case .messageStatus(let status):
				switch status {
				case .failed, .bounced:
					return imageFromFramework(named: "bounced")
				case .delivered:
					return imageFromFramework(named: "delivered")
				case .sent:
					return imageFromFramework(named: "sent")
				case .sending:
					return imageFromFramework(named: "not-sent")
				case .yetToSend, .seen, .custom:
					return UIImage()
				}
			case .backButton:
				return imageFromFramework(named: "Back-Icon")
			case .background(let pattern, let tone):
				let imageName = pattern.rawValue.capitalized + "-" + tone.rawValue.capitalized
				return imageFromFramework(named: imageName)
			case .file(let type):
				switch type {
				case .adobe(let adobeType):
					switch adobeType {
					case .illustrator:
						return imageFromFramework(named: "AI File")
					case .photoshop:
						return imageFromFramework(named: "PS File")
					case .xd:
						return imageFromFramework(named: "XD File")
					}
				case .audio:
					return imageFromFramework(named: "Audio File")
				case .css:
					return imageFromFramework(named: "CSS File")
				case .doc:
					return imageFromFramework(named: "Doc File")
				case .excel:
					return imageFromFramework(named: "Excel File")
				case .html:
					return imageFromFramework(named: "HTML File")
				case .other:
					return imageFromFramework(named: "Generic File")
				case .pdf:
					return imageFromFramework(named: "PDF File")
				case .sketch:
					return imageFromFramework(named: "Sketch File")
				case .txt:
					return imageFromFramework(named: "Text File")
				case .video:
					return imageFromFramework(named: "Video File")
				case .zip:
					return imageFromFramework(named: "Zip File")
				default:
					return imageFromFramework(named: "Generic File")
				}
			case .blob(let type, let selectedState):
				let imageName = "\(type.rawValue.capitalized) \(selectedState.rawValue.capitalized) Blob"
				return imageFromFramework(named: imageName)
			}

		}()
		
		if let image = imageFromBundle {
			return image
		} else {
			#if DEBUG
				fatalError("Background image not found")
			#else
				return UIImage()
			#endif
		}
	}
	
	func imageFromFramework(named name: String) -> UIImage? {
		let bundle = Bundle(for: fakeResourceClass.self)
		print(bundle.bundleURL)
		if let kayakoMessengerBundlePath = bundle.path(forResource: "Kayako-Messenger", ofType: "bundle"),
			let kayakoMessengerBundle = Bundle(path: kayakoMessengerBundlePath),
			let image = UIImage(named: name, in: kayakoMessengerBundle, compatibleWith: nil) {
			return image
		}
		
		if let image = UIImage(named: name) {
			return image
		}
		return UIImage(named: name, in: bundle, compatibleWith: nil)
	}
	
	static var frameworkResourceBundle: Bundle = {
		let bundle = Bundle(for: fakeResourceClass.self)
		if let kayakoMessengerBundlePath = bundle.path(forResource: "Kayako-Messenger", ofType: "bundle"),
			let kayakoMessengerBundle = Bundle(path: kayakoMessengerBundlePath) {
			return kayakoMessengerBundle
		}
		return bundle
	}()
}

class fakeResourceClass {
}
