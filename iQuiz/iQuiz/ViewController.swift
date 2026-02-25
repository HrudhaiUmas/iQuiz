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

        // Gear button -> Apple Settings app (Part 4 requirement)
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "gearshape.fill"),
            style: .plain,
            target: self,
            action: #selector(openAppSettings)
        )

        // Optional manual refresh button (keeps a visible "check now" style action)
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .refresh,
            target: self,
            action: #selector(checkNowTapped)
        )

        // Pull to refresh (extra credit from Part 3)
        let rc = UIRefreshControl()
        rc.addTarget(self, action: #selector(handlePullToRefresh), for: .valueChanged)
        refreshControl = rc

        // If returning from Apple Settings, reload UI and timer settings
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
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

    @objc private func appDidBecomeActive() {
        // Picks up URL / refresh interval changes from Apple Settings app
        configureAutoRefreshTimer()
        tableView.reloadData()
    }

    // MARK: - Part 4: Open Apple Settings app
    @objc private func openAppSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }

        if UIApplication.shared.canOpenURL(settingsURL) {
            UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
        }
    }

    // MARK: - Manual check now
    @objc private func checkNowTapped() {
        downloadQuizzes(showSuccessAlert: true)
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

        if refreshControl?.isRefreshing == false {
            refreshControl?.beginRefreshing()
            if tableView.contentOffset.y >= 0 {
                tableView.setContentOffset(CGPoint(x: 0, y: -(refreshControl?.frame.height ?? 0)), animated: true)
            }
        }

        QuizNetworkService.shared.fetchQuizzes(from: urlString) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }

                self.refreshControl?.endRefreshing()

                switch result {
                case .success(let downloadedQuizzes):
                    // Part 4: this also saves to local storage via QuizSession
                    self.session.replaceQuizzes(with: downloadedQuizzes)
                    self.tableView.reloadData()

                    if showSuccessAlert {
                        let alert = UIAlertController(
                            title: "Updated",
                            message: "Quiz data downloaded successfully.",
                            preferredStyle: .alert
                        )
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(alert, animated: true)
                    }

                case .failure(let error):
                    // If offline, app still has local cache from startup (Part 4)
                    let title = error.localizedDescription.lowercased().contains("network")
                        ? "Network Unavailable"
                        : "Update Failed"

                    let alert = UIAlertController(
                        title: title,
                        message: error.localizedDescription,
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
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

    // MARK: - Segue prep
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toQuestion" {
            // QuizSession.shared is used by next screens
        }
    }
}
