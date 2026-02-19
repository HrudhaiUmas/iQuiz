//
//  AnswerViewController.swift
//  iQuiz
//
//  Created by Hrudhai Umas on 2/17/26.
//

import UIKit

class AnswerViewController: UIViewController {

    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var correctAnswerLabel: UILabel!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!

    private let session = QuizSession.shared

    override func viewDidLoad() {
        super.viewDidLoad()

        title = session.currentQuiz.title
        navigationItem.prompt = "Swipe → Next   Swipe ← Quit"

        // Back should return to main list
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Back",
            style: .plain,
            target: self,
            action: #selector(backToTopics)
        )

        // Swipe gestures (extra credit)
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeRight))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)

        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeLeft))
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeLeft)

        showResultsAndScoreOnce()
    }

    private func showResultsAndScoreOnce() {
        let q = session.currentQuestion

        questionLabel.text = q.text
        correctAnswerLabel.text = "Correct answer: \(q.answers[q.correctIndex])"

        let selected = session.selectedAnswerIndex ?? -1
        let isCorrect = (selected == q.correctIndex)

        if isCorrect {
            resultLabel.text = "✅ Correct!"
            session.numCorrect += 1
        } else {
            resultLabel.text = "❌ Wrong!"
        }
    }

    @objc private func backToTopics() {
        session.abandonQuiz()
        navigationController?.popToRootViewController(animated: true)
    }

    @objc private func handleSwipeRight() {
        nextTapped(nextButton as Any)
    }

    @objc private func handleSwipeLeft() {
        backToTopics()
    }

    // MARK: - Next
    @IBAction func nextTapped(_ sender: Any) {

        if session.isLastQuestion() {
            performSegue(withIdentifier: "toFinished", sender: self)
        } else {
            session.goToNextQuestion()
            performSegue(withIdentifier: "toNextQuestion", sender: self)
        }
    }
}
