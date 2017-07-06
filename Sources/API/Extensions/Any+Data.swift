//
//  Any+Data.swift
//  kayako-messenger-SDK
//
//  Created by Robin Malhotra on 07/04/17.
//  Copyright © 2017 Robin Malhotra. All rights reserved.
//

import Foundation
import Wrap

//: Had to make function because Any can't be extended
public func objectToData(object: Any) -> Data {
	do {
		let dict = try wrap(object) as [String: Any]
		let stringDict = try dict.urlEncodedString()
		if let data = stringDict.data(using: .utf8) {
			return data
		} else {
			throw CreationWrapError.utf8ConversionFailed
		}
	} catch {
		#if DEBUG
			fatalError("model to data conversion failed with error: \(error)")
		#else
			return Data()
		#endif
		
	}
}
