//
//  CardPresentationManager.swift
//  kayako-messenger-SDK
//
//  Created by Robin Malhotra on 06/03/17.
//  Copyright © 2017 Robin Malhotra. All rights reserved.
//

import UIKit

class CardPresentationController: UIPresentationController {
	
	let tappableDismissView: UIView
	
	override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
		
		self.tappableDismissView = UIView()
		super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
		
		let tapGR = UITapGestureRecognizer(target: self, action: #selector(self.dismissViewTapped))
		tappableDismissView.addGestureRecognizer(tapGR)
		tappableDismissView.backgroundColor = .clear
		
	}
	
	func dismissViewTapped() {
		presentingViewController.dismiss(animated: true) { 
			print("dismissed")
			print(self.presentingViewController)
		}
	}
	
	override func presentationTransitionWillBegin() {
		
		guard let fromView = self.presentingViewController.view else {
			return
		}
		
		let behindTransform = CGAffineTransform(scaleX: 0.9, y: 0.9)
//		let snapshot = UIImageView(image: fromView.getSnapshotImage())
		containerView?.addSubview(fromView)
		
		tappableDismissView.frame = CGRect(x: 0, y: 0, width: containerView?.frame.width ?? 0, height: CardPresentationManager.cardOffset)
		containerView?.addSubview(tappableDismissView)
		
		presentedViewController.transitionCoordinator?.animate(alongsideTransition: { (context) in
			fromView.transform = behindTransform
		}, completion: { context in
		})
	}
	
	override func dismissalTransitionWillBegin() {
		guard let toView = self.presentingViewController.view else {
			return
		}
//		self.containerView?.addSubview(toView)
		presentingViewController.transitionCoordinator?.animate(alongsideTransition: { (context) in
			toView.transform = .identity
		}, completion: { (context) in
			UIApplication.shared.keyWindow!.addSubview(toView)
		})
	}
	
	override func dismissalTransitionDidEnd(_ completed: Bool) {
		self.tappableDismissView.removeFromSuperview()
	}
}

open class CardTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
	
	public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
		let pres = CardPresentationController(presentedViewController: presented, presenting: presenting)
		return pres
	}
	
	public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return CardPresentationManager()
	}
	
	public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return CardDismissalManager()
	}
	
}

class CardPresentationManager: NSObject, UIViewControllerAnimatedTransitioning {
	
	static let cardOffset = CGFloat(40)
	static let scaleFactor = 0.95
	
	public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
		
		let container = transitionContext.containerView
		guard let toView = transitionContext.view(forKey: UITransitionContextViewKey.to) else {
				return
		}
		
		let bottomTransform = CGAffineTransform(translationX: 0, y: container.frame.height)
		
		toView.transform = bottomTransform
		
		let duration = self.transitionDuration(using: transitionContext)
		
		container.addSubview(toView)
		
		UIView.animate(withDuration: duration, animations: {
			toView.frame = CGRect(x: 0, y: CardPresentationManager.cardOffset, width: container.frame.width, height: container.frame.height - CardPresentationManager.cardOffset)
		}) { (completed) in
			transitionContext.completeTransition(completed)
		}
	}

	
	func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		return 0.25
	}
	
}

class CardDismissalManager: NSObject, UIViewControllerAnimatedTransitioning {
	public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
		
		let container = transitionContext.containerView
		guard let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from) else { return }
		
		let duration = self.transitionDuration(using: transitionContext)
		
		fromView.frame = CGRect(x: 0, y: CardPresentationManager.cardOffset, width: container.frame.width, height: container.frame.height - CardPresentationManager.cardOffset)
		
		
		UIView.animate(withDuration: duration, animations: {
			fromView.frame = CGRect(x: 0, y: container.frame.height, width: fromView.frame.width, height: fromView.frame.height)
		}) { (completed) in
			transitionContext.completeTransition(completed)
		}
	}
	
	
	func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		return 0.25
	}
}
