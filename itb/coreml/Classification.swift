//
//  Classification.swift
//  itb
//
//  Created by Mongkon Srisin on 11/24/18.
//  Copyright © 2018 Mongkon Srisin. All rights reserved.
//

import Foundation

public struct Classification {
    
    public enum Category: String {
        case business = "Business"
        case entertainment = "Entertainment"
        case politics = "Politics"
        case sports = "Sports"
        case technology = "Technology"
    }
    
    public struct Result {
        public let category: Category
        public let probability: Double
    }
    
    public let prediction: Result
    public let allResults: [Result]
    
}

extension Classification {
    
    init?(output: DocumentClassificationOutput) {
        guard let category = Category(rawValue: output.classLabel),
            let probability = output.classProbability[output.classLabel]
            else { return nil }
        let prediction = Result(category: category, probability: probability)
        let allResults = output.classProbability.compactMap(Classification.result)
        self.init(prediction: prediction, allResults: allResults)
    }
    
    static func result(from classProbability: (key: String, value: Double)) -> Result? {
        guard let category = Category(rawValue: classProbability.key) else { return nil }
        return Result(category: category, probability: classProbability.value)
    }
}
