//
//  SentimentService.swift
//  itb
//
//  Created by Mongkon Srisin on 11/23/18.
//  Copyright © 2018 Mongkon Srisin. All rights reserved.
//

import CoreML

struct SentimentObj {
    var sentiment:Sentiment
    var score:Double
}

final class SentimentService {
    
   private enum Error: Swift.Error {
        case featuresMissing
    }
    
    private let model = SentimentPolarity()
    private let options: NSLinguisticTagger.Options = [.omitWhitespace, .omitPunctuation, .omitOther]
    private lazy var tagger: NSLinguisticTagger = .init(
        tagSchemes: NSLinguisticTagger.availableTagSchemes(forLanguage: "en"),
        options: Int(self.options.rawValue)
    )
    
    func predictSentiment(from text: String) -> SentimentObj {
        do {
            let inputFeatures = features(from: text)
            // Make prediction only with 2 or more words
            guard inputFeatures.count > 1 else {
                throw Error.featuresMissing
            }
            
            let output = try model.prediction(input: inputFeatures)
            switch output.classLabel {
            case "Pos":
                return SentimentObj(sentiment: .positive, score: output.classProbability["Pos"]!)
            case "Neg":
                return SentimentObj(sentiment: .negative, score: output.classProbability["Neg"]!)
            default:
                return SentimentObj(sentiment: .neutral, score: 0.00)
            }
        } catch {
            return SentimentObj(sentiment: .neutral, score: 0.00)
        }
    }
    
}

private extension SentimentService {
    func features(from text: String) -> [String: Double] {
        var wordCounts = [String: Double]()
        
        tagger.string = text
        let range = NSRange(location: 0, length: text.utf16.count)
        
        // Tokenize and count the sentence
        tagger.enumerateTags(in: range, scheme: .nameType, options: options) { _, tokenRange, _, _ in
            let token = (text as NSString).substring(with: tokenRange).lowercased()
            // Skip small words
            guard token.count >= 3 else {
                return
            }
            
            if let value = wordCounts[token] {
                wordCounts[token] = value + 1.0
            } else {
                wordCounts[token] = 1.0
            }
        }
        
        return wordCounts
    }
}

