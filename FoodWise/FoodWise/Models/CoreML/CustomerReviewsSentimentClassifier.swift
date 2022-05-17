//
//  CustomerReviewsSentimentClassifier.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 22/04/22.
//

import Foundation
import CoreML
import NaturalLanguage

struct CustomerReviewsSentimentClassifier {
  private var mlModel: MLModel
  private var sentimentPredictor: NLModel
  
  init() {
    do {
      self.mlModel = try SentimentClassifier(configuration: MLModelConfiguration()).model
      do {
        self.sentimentPredictor = try NLModel(mlModel: self.mlModel)
      } catch {
        fatalError("Unable to initialize the NL Model: \(error)")
      }
    } catch {
      fatalError("Unable to initialize ML Model: \(error)")
    }
  }
  
  func makePredictionFor(aReview review: String) -> PredictionResult? {
    let label = sentimentPredictor.predictedLabel(for: review.lowercased()) ?? ""
    let predictions = sentimentPredictor.predictedLabelHypotheses(for: review, maximumCount: 5)
    guard let confidence = predictions[label],
          let labelValue = Float(label) else { return nil }
    return PredictionResult(labelValue: labelValue, confidence: confidence)
  }
}

extension CustomerReviewsSentimentClassifier {
  struct PredictionResult {
    let labelValue: Float
    let confidence: Double
  }
  
  static var NeutralSentimentScore: Float { 3.0 }
}
