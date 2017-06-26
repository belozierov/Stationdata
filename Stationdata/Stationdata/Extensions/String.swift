//
//  String.swift
//  Stationdata
//
//  Created by Beloizerov on 26.06.17.
//  Copyright © 2017 Beloizerov. All rights reserved.
//

import Foundation

extension String {
    
    subscript (_ r: Range<Int>) -> String {
        let start = index(startIndex, offsetBy: r.lowerBound)
        let end = index(start, offsetBy: r.upperBound - r.lowerBound)
        return self[start..<end]
    }
    
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
}
