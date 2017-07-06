//
//  ViewController.swift
//  MessengerExample
//
//  Created by Robin Malhotra on 06/07/17.
//  Copyright © 2017 Kayako. All rights reserved.
//

import UIKit
import KayakoMessenger

class ViewController: UIViewController {

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		presentMessenger(in: self)
		// Do any additional setup after loading the view, typically from a nib.
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


}

func presentMessenger(in viewController: UIViewController) {
	let config = Configuration(brandName: "Kayako", instanceURL: URL(string: "kayako-mobile-testing.kayako.com")!, authorization: .auto, background: .patternGradient(BackgroundPattern.confetti.image(tone: .light), GradientColor.eggPlant.colors), primaryColor: UIColor(red:0.95, green:0.44, blue:0.25, alpha:1.00), homeTitle: "Good Morning ☕️", homeSubtitle: "The real coffee experts. How can we help?", homeTextColor: .white)
	
	let conversationNav = CustomerSuccessController(config: config)
	conversationNav.modalPresentationStyle = .custom
	let cardTransitionDelegate = CardTransitioningDelegate()
	conversationNav.transitioningDelegate = cardTransitionDelegate
	viewController.present(conversationNav, animated: true) { }
}
