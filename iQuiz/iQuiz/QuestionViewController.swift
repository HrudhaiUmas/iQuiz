//
//  QuestionViewController.swift
//  iQuiz
//
//  Created by Hrudhai Umas on 2/17/26.
//

import UIKit

class QuestionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answersTableView: UITableView!
    @IBOutlet weak var submitButton: UIButton!

    private let session = QuizSession.shared

    override func viewDidLoad() {
        super.viewDidLoad()

        title = session.currentQuiz.title

        // Discoverability for swipe gestures (extra credit)
        navigationItem.prompt = "Swipe → Submit   Swipe ← Quit"

        // Back should return to main list (rubric requirement)
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Back",
            style: .plain,
            target: self,
            action: #selector(backToTopics)
        )

        answersTableView.dataSource = self
        answersTableView.delegate = self
        answersTableView.allowsMultipleSelection = false

        // Swipe gestures (extra credit)
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeRight))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)

        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeLeft))
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeLeft)

        refreshUI()
    }

    private func refreshUI() {
        let q = session.currentQuestion
        questionLabel.text = q.text
        answersTableView.reloadData()
    }

    @objc private func backToTopics() {
        session.abandonQuiz()
        navigationController?.popToRootViewController(animated: true)
    }

    // MARK: - Swipe handlers
    @objc private func handleSwipeRight() {
        submitTapped(submitButton as Any)
    }

    @objc private func handleSwipeLeft() {
        backToTopics()
    }

    // MARK: - Submit
    @IBAction func submitTapped(_ sender: Any) {

        guard session.selectedAnswerIndex != nil else {
            let alert = UIAlertController(title: "Select an answer",
                                          message: "Please choose one option before submitting.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        performSegue(withIdentifier: "toAnswer", sender: self)
    }

    // MARK: - Table Data Source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        session.currentQuestion.answers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let reuseId = "AnswerCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseId)
            ?? UITableViewCell(style: .default, reuseIdentifier: reuseId)

        cell.textLabel?.text = session.currentQuestion.answers[indexPath.row]

        // Show checkmark for selected answer
        if session.selectedAnswerIndex == indexPath.row {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }

        return cell
    }

    // MARK: - Single selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        session.selectedAnswerIndex = indexPath.row
        tableView.reloadData()
    }
}
