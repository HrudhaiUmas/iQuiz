//
//  QuizSession.swift
//  iQuiz
//
//  Created by Hrudhai Umas on 2/17/26.
//

import Foundation

final class QuizSession {

    static let shared = QuizSession()

    private init() {
        quizzes = QuizSession.defaultQuizzes()
    }

    // All quizzes for the app (mutable now so network can replace them)
    private(set) var quizzes: [Quiz]

    static func defaultQuizzes() -> [Quiz] {
        [
            Quiz(
                title: "Mathematics",
                description: "Test your math skills!",
                iconSystemName: "function",
                questions: [
                    Question(text: "What is 15% of 80?",
                             answers: ["10", "12", "15", "18"],
                             correctIndex: 1),
                    Question(text: "Which number is prime?",
                             answers: ["21", "27", "29", "33"],
                             correctIndex: 2),
                    Question(text: "Solve: 3(x + 4) = 24. What is x?",
                             answers: ["2", "3", "4", "6"],
                             correctIndex: 2)
                ]
            ),
            Quiz(
                title: "Marvel Super Heroes",
                description: "Test how well you know Marvel!",
                iconSystemName: "bolt.fill",
                questions: [
                    Question(text: "What is Black Panther’s home country?",
                             answers: ["Wakanda", "Genosha", "Latveria", "Sokovia"],
                             correctIndex: 0),
                    Question(text: "Who is Tony Stark’s AI assistant in the early MCU?",
                             answers: ["FRIDAY", "JARVIS", "KAREN", "EDITH"],
                             correctIndex: 1),
                    Question(text: "Which Infinity Stone is in the Tesseract?",
                             answers: ["Mind", "Power", "Space", "Time"],
                             correctIndex: 2)
                ]
            ),
            Quiz(
                title: "Science",
                description: "Test your science skills!",
                iconSystemName: "atom",
                questions: [
                    Question(text: "What gas do plants primarily absorb from the air?",
                             answers: ["Oxygen", "Nitrogen", "Carbon dioxide", "Helium"],
                             correctIndex: 2),
                    Question(text: "What is the chemical symbol for gold?",
                             answers: ["Ag", "Au", "Gd", "Go"],
                             correctIndex: 1),
                    Question(text: "Which part of the cell contains DNA?",
                             answers: ["Ribosome", "Nucleus", "Cell wall", "Cytoplasm"],
                             correctIndex: 1)
                ]
            )
        ]
    }

    func replaceQuizzes(with newQuizzes: [Quiz]) {
        guard newQuizzes.isEmpty == false else { return }

        quizzes = newQuizzes

        // Reset any in-progress state so indices stay valid
        currentQuizIndex = 0
        currentQuestionIndex = 0
        numCorrect = 0
        selectedAnswerIndex = nil
    }

    // Current run state
    var currentQuizIndex: Int = 0
    var currentQuestionIndex: Int = 0
    var numCorrect: Int = 0
    var selectedAnswerIndex: Int? = nil

    func startQuiz(quizIndex: Int) {
        currentQuizIndex = quizIndex
        currentQuestionIndex = 0
        numCorrect = 0
        selectedAnswerIndex = nil
    }

    func abandonQuiz() {
        currentQuestionIndex = 0
        numCorrect = 0
        selectedAnswerIndex = nil
    }

    var currentQuiz: Quiz {
        quizzes[currentQuizIndex]
    }

    var currentQuestion: Question {
        currentQuiz.questions[currentQuestionIndex]
    }

    var totalQuestions: Int {
        currentQuiz.questions.count
    }

    func isLastQuestion() -> Bool {
        return currentQuestionIndex >= (totalQuestions - 1)
    }

    func goToNextQuestion() {
        currentQuestionIndex += 1
        selectedAnswerIndex = nil
    }
}
