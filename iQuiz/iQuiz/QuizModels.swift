//
//  QuizModels.swift
//  iQuiz
//
//  Created by Hrudhai Umas on 2/17/26.
//

import Foundation

struct Question {
    let text: String
    let answers: [String]
    let correctIndex: Int
}

struct Quiz {
    let title: String
    let description: String
    let iconSystemName: String
    let questions: [Question]
}
