//
//  CustomerSuccessController.swift
//  kayako-messenger-SDK
//
//  Created by Robin Malhotra on 06/03/17.
//  Copyright © 2017 Robin Malhotra. All rights reserved.
//

import UIKit


open class CustomerSuccessController: UINavigationController {
	
	var config: Configuration
	
	public init(config: Configuration) {
		self.config = config
		super.init(nibName: nil, bundle: nil)
		Client.shared = Client(baseURL: config.instanceURL.absoluteString, auth: config.authorization)
		KREClient.shared = KREClient(instance: config.instanceURL.absoluteString, auth: config.authorization)
	}
	
	required public init?(coder aDecoder: NSCoder) {
		self.config = Configuration(brandName: "Kayako", instanceURL: URL(string: "kayako-mobile-testing.kayako.com")!, authorization: .manual(Authorization.fingerprints(fingerprintID: UUID().uuidString, userInfo: nil)), background: .flatColor(.red), primaryColor: .orange, homeTitle: "", homeSubtitle: "",  homeTextColor: .white)
		super.init(coder: aDecoder)
	}

    override open func viewDidLoad() {
        super.viewDidLoad()
		
		let homescreen = HomeScreenViewController(configuration: config)
		self.viewControllers = [homescreen]
		
		// Do any additional setup after loading the view.
    }
	
	override open func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
	}

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
