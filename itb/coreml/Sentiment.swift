//
//  Sentiment.swift
//  itb
//
//  Created by Mongkon Srisin on 11/23/18.
//  Copyright © 2018 Mongkon Srisin. All rights reserved.
//

import UIKit

enum Sentiment {
    case neutral
    case positive
    case negative
    
    var emoji: String {
        switch self {
        case .neutral:
            return ""
        case .positive:
            return "😀"
        case .negative:
            return "😡"
        }
    }
    
}
