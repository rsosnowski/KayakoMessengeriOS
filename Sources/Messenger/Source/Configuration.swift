//
//  Configuration.swift
//  kayako-messenger-SDK
//
//  Created by Robin Malhotra on 30/03/17.
//  Copyright © 2017 Robin Malhotra. All rights reserved.
//

import UIKit


public enum AuthorizationCreation {
	case auto
	case manual(Authorization)
}

public struct Configuration {
	let brandName: String
	let instanceURL: URL
	
	let authorization: Authorization
	
	let background: Background
	let primaryColor: UIColor
	
	let homeTitle: String
	let homeSubtitle: String
	let homeTextColor: UIColor
	
	public static let placeholder = Configuration(brandName: "", instanceURL: URL(string: "kayako-mobile-testing.kayako.com")!, authorization: .manual(.fingerprints(fingerprintID: "", userInfo: nil)), background: Background.flatColor(.black), primaryColor: .black, homeTitle: "", homeSubtitle: "", homeTextColor: .white)
	
	public init(brandName: String, instanceURL: URL, authorization authCreation: AuthorizationCreation, background: Background, primaryColor: UIColor, homeTitle: String, homeSubtitle: String, homeTextColor: UIColor) {
		self.brandName = brandName
		self.instanceURL = instanceURL
		switch authCreation {
		case .auto:
			let defaults = UserDefaults.standard
			if let email = defaults.object(forKey: "Kayako.UserLoginInfo.email") as? String,
				let name = defaults.object(forKey: "Kayako.UserLoginInfo.name") as? String,
				let fingerprintID = defaults.object(forKey: "Kayako.fingerprintID") as? String,
				let userLoginInfo = try? UserLoginInfo(email: email, name: name) {
					self.authorization = .fingerprints(fingerprintID: fingerprintID, userInfo: userLoginInfo)
			} else {
				let uuid = UUID().uuidString
				defaults.set(uuid, forKey: "Kayako.fingerprintID")
				defaults.synchronize()
				self.authorization = .fingerprints(fingerprintID: uuid, userInfo: nil)
			}
		case .manual(let authorization):
			self.authorization = authorization
		}
		self.background = background
		self.primaryColor = primaryColor
		self.homeTitle = homeTitle
		self.homeSubtitle = homeSubtitle
		self.homeTextColor = homeTextColor
	}
}
