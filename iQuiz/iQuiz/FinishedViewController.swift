//
//  FinishedViewController.swift
//  iQuiz
//
//  Created by Hrudhai Umas on 2/17/26.
//

import UIKit

class FinishedViewController: UIViewController {

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!

    private let session = QuizSession.shared

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Finished"

        // Back returns to main list
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Back",
            style: .plain,
            target: self,
            action: #selector(backToTopics)
        )

        let total = session.totalQuestions
        let correct = session.numCorrect

        scoreLabel.text = "\(correct) of \(total) correct"

        if correct == total {
            messageLabel.text = "Perfect!"
        } else if correct >= total - 1 {
            messageLabel.text = "Almost!"
        } else if correct >= total / 2 {
            messageLabel.text = "Not bad!"
        } else {
            messageLabel.text = "Keep trying!"
        }
    }

    @objc private func backToTopics() {
        session.abandonQuiz()
        navigationController?.popToRootViewController(animated: true)
    }

    // Next button: “continue” -> go back to list (new quiz)
    @IBAction func nextTapped(_ sender: Any) {
        session.abandonQuiz()
        navigationController?.popToRootViewController(animated: true)
    }
}

