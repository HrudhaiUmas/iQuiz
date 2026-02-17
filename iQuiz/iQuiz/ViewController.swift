//
//  ViewController.swift
//  iQuiz
//
//  Created by Hrudhai Umas on 2/16/26.
//

import UIKit

// MARK: - Model
struct QuizTopic {
    let title: String
    let description: String
    let iconSystemName: String
}

class ViewController: UITableViewController {

    // In-memory array (Part 1 requirement)
    private let quizzes: [QuizTopic] = [
        QuizTopic(title: "Mathematics",
                  description: "Test your math skills!",
                  iconSystemName: "function"),

        QuizTopic(title: "Marvel Super Heroes",
                  description: "Test how well you know Marvel!",
                  iconSystemName: "bolt.fill"),

        QuizTopic(title: "Science",
                  description: "Test your science skills!",
                  iconSystemName: "atom")
    ]

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

    // MARK: - Settings Alert
    @objc private func didTapSettings()
    {
        let alert = UIAlertController(
            title: "Settings",
            message: "Settings go here",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }

    // MARK: - TableView Data Source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return quizzes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let reuseId = "QuizCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseId)
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: reuseId)

        let quiz = quizzes[indexPath.row]

        cell.textLabel?.text = quiz.title
        cell.detailTextLabel?.text = quiz.description
        cell.detailTextLabel?.textColor = .secondaryLabel

        cell.imageView?.image = UIImage(systemName: quiz.iconSystemName)
        cell.imageView?.tintColor = .systemBlue

        return cell
    }
}
