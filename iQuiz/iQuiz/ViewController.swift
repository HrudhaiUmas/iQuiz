//
//  ViewController.swift
//  iQuiz
//
//  Created by Hrudhai Umas on 2/16/26.
//

import UIKit

class ViewController: UITableViewController {

    private let session = QuizSession.shared
    private var autoRefreshTimer: Timer?

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

        // Extra credit: Pull to refresh
        let rc = UIRefreshControl()
        rc.addTarget(self, action: #selector(handlePullToRefresh), for: .valueChanged)
        refreshControl = rc
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureAutoRefreshTimer()
        tableView.reloadData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        autoRefreshTimer?.invalidate()
        autoRefreshTimer = nil
    }

    // MARK: - Settings (URL + Check Now + persistence)
    @objc private func didTapSettings() {
        let alert = UIAlertController(
            title: "Settings",
            message: "Quiz source URL and refresh options",
            preferredStyle: .alert
        )

        // URL field
        alert.addTextField { textField in
            textField.placeholder = "Quiz JSON URL"
            textField.text = AppSettings.sourceURLString
            textField.keyboardType = .URL
            textField.autocapitalizationType = .none
            textField.autocorrectionType = .no
            textField.clearButtonMode = .whileEditing
        }

        // Extra credit: timed refresh interval field (minutes)
        alert.addTextField { textField in
            textField.placeholder = "Auto refresh (minutes, 0 = off)"
            let interval = AppSettings.autoRefreshMinutes
            textField.text = interval == 0 ? "0" : String(interval)
            textField.keyboardType = .decimalPad
        }

        func readFieldsAndPersist() -> (url: String, interval: Double) {
            let urlText = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? AppSettings.defaultQuizURL
            let intervalText = alert.textFields?.dropFirst().first?.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "0"
            let interval = max(0, Double(intervalText) ?? 0)

            AppSettings.sourceURLString = urlText.isEmpty ? AppSettings.defaultQuizURL : urlText
            AppSettings.autoRefreshMinutes = interval

            return (AppSettings.sourceURLString, interval)
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak self] _ in
            _ = readFieldsAndPersist()
            self?.configureAutoRefreshTimer()
        }))

        alert.addAction(UIAlertAction(title: "Check Now", style: .default, handler: { [weak self] _ in
            _ = readFieldsAndPersist()
            self?.configureAutoRefreshTimer()
            self?.downloadQuizzes(showSuccessAlert: true)
        }))

        present(alert, animated: true)
    }

    // MARK: - Pull to Refresh (Extra Credit)
    @objc private func handlePullToRefresh() {
        downloadQuizzes(showSuccessAlert: false)
    }

    // MARK: - Timed Refresh (Extra Credit)
    private func configureAutoRefreshTimer() {
        autoRefreshTimer?.invalidate()
        autoRefreshTimer = nil

        let minutes = AppSettings.autoRefreshMinutes
        guard minutes > 0 else { return }

        autoRefreshTimer = Timer.scheduledTimer(withTimeInterval: minutes * 60.0, repeats: true) { [weak self] _ in
            self?.downloadQuizzes(showSuccessAlert: false)
        }
    }

    // MARK: - Networking
    private func downloadQuizzes(showSuccessAlert: Bool) {
        let urlString = AppSettings.sourceURLString

        // If manually triggered and not already showing refresh spinner, show one.
        if refreshControl?.isRefreshing == false {
            refreshControl?.beginRefreshing()
            // Make spinner visible if table is at top
            if tableView.contentOffset.y >= 0 {
                tableView.setContentOffset(CGPoint(x: 0, y: -((refreshControl?.frame.height ?? 0))), animated: true)
            }
        }

        QuizNetworkService.shared.fetchQuizzes(from: urlString) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }

                self.refreshControl?.endRefreshing()

                switch result {
                case .success(let downloadedQuizzes):
                    self.session.replaceQuizzes(with: downloadedQuizzes)
                    self.tableView.reloadData()

                    if showSuccessAlert {
                        let successAlert = UIAlertController(
                            title: "Updated",
                            message: "Quiz data downloaded successfully.",
                            preferredStyle: .alert
                        )
                        successAlert.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(successAlert, animated: true)
                    }

                case .failure(let error):
                    // notify if network not available / issues occur
                    let title = (error == .noInternet) ? "Network Unavailable" : "Update Failed"

                    let failureAlert = UIAlertController(
                        title: title,
                        message: error.localizedDescription,
                        preferredStyle: .alert
                    )
                    failureAlert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(failureAlert, animated: true)
                }
            }
        }
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
            // QuizSession.shared is used by the next screens
        }
    }
}

// Small helper so we can compare QuizFetchError values for title choice
private extension QuizFetchError {
    static func == (lhs: QuizFetchError, rhs: QuizFetchError) -> Bool {
        switch (lhs, rhs) {
        case (.noInternet, .noInternet): return true
        default: return false
        }
    }
}
