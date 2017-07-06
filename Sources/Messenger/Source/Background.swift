//
//  Background.swift
//  kayako-messenger-SDK
//
//  Created by Robin Malhotra on 24/03/17.
//  Copyright © 2017 Robin Malhotra. All rights reserved.
//

import UIKit


public enum BackgroundTone: String {
	case light
	case dark
}

public enum Background {
	case flatColor(UIColor)
	case customGradient([UIColor])
	case image(UIImage)
	case patternColor(UIImage, UIColor)
	case patternGradient(UIImage, [UIColor])
}


public enum BackgroundPattern: String {
	case cheerios
	case confetti
	case constellation
	case dots
	case mosaic
	case nachos
	case polka
	case sand
	case stars
	case zigzag
	
	public func image(tone: BackgroundTone) -> UIImage {
		return KayakoResources.background(self, tone).image
	}
}

public enum FlatColor {
	
	case red
	case orange
	case yellow
	case green
	case teal
	case blue
	case purple
	
	public var colorValue: UIColor {
		switch self {
		case .red:
			return UIColor(red:1.00, green:0.23, blue:0.19, alpha:1.00)
		case .orange:
			return UIColor(red:1.00, green:0.58, blue:0.00, alpha:1.00)
		case .yellow:
			return UIColor(red:1.00, green:0.80, blue:0.00, alpha:1.00)
		case .green:
			return UIColor(red:0.30, green:0.85, blue:0.39, alpha:1.00)
		case .teal:
			return UIColor(red:0.35, green:0.78, blue:0.98, alpha:1.00)
		case .blue:
			return UIColor(red:0.00, green:0.48, blue:1.00, alpha:1.00)
		case .purple:
			return UIColor(red:0.35, green:0.34, blue:0.84, alpha:1.00)
		}
	}
}

public enum GradientColor {
	case beetroot
	case peach
	case rawMango
	case greenApple
	case aqua
	case midnightBlue
	case eggPlant
	
	public var colors: [UIColor] {
		switch self {
		case .beetroot:
			return [UIColor(red:0.81, green:0.16, blue:0.49, alpha:1.00),
			        UIColor(red:1.00, green:0.23, blue:0.19, alpha:1.00)]
		case .peach:
			return [UIColor(red:0.95, green:0.31, blue:0.55, alpha:1.00),
			        UIColor(red:1.00, green:0.92, blue:0.00, alpha:1.00)]
		case .rawMango:
			return [UIColor(red:1.00, green:0.80, blue:0.00, alpha:1.00),
			        UIColor(red:0.33, green:0.86, blue:0.57, alpha:1.00)]
		case .greenApple:
			return [UIColor(red:0.14, green:0.66, blue:0.46, alpha:1.00),
					UIColor(red:0.73, green:0.83, blue:0.24, alpha:1.00)]
		case .aqua:
			return [UIColor(red:0.05, green:0.87, blue:0.66, alpha:1.00),
					UIColor(red:0.35, green:0.78, blue:0.98, alpha:1.00)]
		case .midnightBlue:
			return [UIColor(red:0.35, green:0.12, blue:0.49, alpha:1.00),
					UIColor(red:0.32, green:0.58, blue:0.97, alpha:1.00)]
		case .eggPlant:
			return [UIColor(red:0.25, green:0.21, blue:0.30, alpha:1.00),
					UIColor(red:0.95, green:0.31, blue:0.55, alpha:1.00)]
		}
	}
}
