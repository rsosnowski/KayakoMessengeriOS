//
//  UIView+Background.swift
//  kayako-messenger-SDK
//
//  Created by Robin Malhotra on 26/04/17.
//  Copyright © 2017 Robin Malhotra. All rights reserved.
//

import UIKit

extension UIView {
	func setBackground(background: Background) {
		switch background {
		case .flatColor(let color):
			self.backgroundColor = color
		case .customGradient(let colors):
			let gradient = CAGradientLayer.init()
			gradient.colors = colors.map{ $0.cgColor }
			gradient.frame = self.bounds
			gradient.startPoint = CGPoint.zero
			gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
			self.layer.insertSublayer(gradient, at: 0)
		case .image(let image):
			self.backgroundColor = UIColor(patternImage: image)
		case .patternColor(let pattern, let color):
			let layer = CALayer()
			let colorLayer = CALayer()
			colorLayer.backgroundColor = color.cgColor
			let patternLayer = CALayer()
			patternLayer.backgroundColor = UIColor(patternImage: pattern).cgColor
			layer.addSublayer(colorLayer)
			layer.addSublayer(patternLayer)
			self.layer.insertSublayer(layer, at: 0)
			layer.frame = self.bounds
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
			self.layer.insertSublayer(layer, at: 0)
			layer.frame = self.bounds
			gradient.frame = layer.bounds
			patternLayer.frame = layer.bounds
		}

	}
}
