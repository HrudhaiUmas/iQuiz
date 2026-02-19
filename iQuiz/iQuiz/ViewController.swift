//
//  ViewController.swift
//  iQuiz
//
//  Created by Hrudhai Umas on 2/16/26.
//

import UIKit

class ViewController: UITableViewController {

    private let session = QuizSession.shared

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "iQuiz"

        // Settings button
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "gearshape.fill"),
            style: .plain,
            target: self,
            action: #selector(didTapSettings)
        )
    }

    // MARK: - Settings Alert (UIAlertController)
    @objc private func didTapSettings() {
        let alert = UIAlertController(
            title: "Settings",
            message: "Settings go here",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }

    // MARK: - TableView Data Source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return session.quizzes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let reuseId = "QuizCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseId)
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: reuseId)

        let quiz = session.quizzes[indexPath.row]

        cell.textLabel?.text = quiz.title
        cell.detailTextLabel?.text = quiz.description
        cell.detailTextLabel?.textColor = .secondaryLabel

        cell.imageView?.image = UIImage(systemName: quiz.iconSystemName)
        cell.imageView?.tintColor = .systemBlue

        cell.accessoryType = .disclosureIndicator
        return cell
    }

    // MARK: - Selection -> First Question (Part 2 requirement)
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        session.startQuiz(quizIndex: indexPath.row)
        performSegue(withIdentifier: "toQuestion", sender: self)
    }

    // MARK: - Pass data to Question scene
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toQuestion" {
            // using QuizSession.shared in next screens
        }
    }
}

