//
//  QuizNetworkService.swift
//  iQuiz
//
//  Created by Hrudhai Umas on 2/23/26.
//

import Foundation
import UIKit

enum QuizFetchError: LocalizedError {
    case invalidURL
    case invalidResponse
    case badStatusCode(Int)
    case noData
    case noInternet
    case decodingFailed
    case emptyQuizData
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The quiz source URL is invalid."
        case .invalidResponse:
            return "The server response was invalid."
        case .badStatusCode(let code):
            return "Server returned status code \(code)."
        case .noData:
            return "No data was returned from the server."
        case .noInternet:
            return "Network is not available. Please check your internet connection."
        case .decodingFailed:
            return "Could not read quiz data from the server."
        case .emptyQuizData:
            return "The server returned quiz data, but no valid quizzes were found."
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}

enum AppSettings {
    static let defaultQuizURL = "http://tednewardsandbox.site44.com/questions.json"

    static let sourceURLKey = "quiz_source_url"
    static let autoRefreshMinutesKey = "quiz_auto_refresh_minutes"

    static func registerDefaults() {
        UserDefaults.standard.register(defaults: [
            sourceURLKey: defaultQuizURL,
            autoRefreshMinutesKey: 0.0
        ])
    }

    static var sourceURLString: String {
        get { UserDefaults.standard.string(forKey: sourceURLKey) ?? defaultQuizURL }
        set { UserDefaults.standard.set(newValue, forKey: sourceURLKey) }
    }

    static var autoRefreshMinutes: Double {
        get {
            let value = UserDefaults.standard.double(forKey: autoRefreshMinutesKey)
            return value
        }
        set {
            UserDefaults.standard.set(newValue, forKey: autoRefreshMinutesKey)
        }
    }
}

// MARK: - Sandbox JSON DTOs
private struct RemoteQuizDTO: Decodable {
    let title: String
    let desc: String
    let questions: [RemoteQuestionDTO]
}

private struct RemoteQuestionDTO: Decodable {
    let text: String
    let answer: String
    let answers: [String]
}

final class QuizNetworkService {

    static let shared = QuizNetworkService()
    private init() {}

    func fetchQuizzes(from urlString: String, completion: @escaping (Result<[Quiz], QuizFetchError>) -> Void) {
        guard let url = URL(string: urlString.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            completion(.failure(.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 12

        URLSession.shared.dataTask(with: request) { data, response, error in

            if let error = error as NSError? {
                if error.domain == NSURLErrorDomain {
                    if error.code == NSURLErrorNotConnectedToInternet ||
                        error.code == NSURLErrorTimedOut ||
                        error.code == NSURLErrorCannotFindHost ||
                        error.code == NSURLErrorCannotConnectToHost ||
                        error.code == NSURLErrorNetworkConnectionLost {
                        completion(.failure(.noInternet))
                        return
                    }
                }

                completion(.failure(.unknown(error)))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponse))
                return
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(.badStatusCode(httpResponse.statusCode)))
                return
            }

            guard let data = data else {
                completion(.failure(.noData))
                return
            }

            do {
                let decoded = try JSONDecoder().decode([RemoteQuizDTO].self, from: data)
                let mapped = self.mapRemoteQuizzes(decoded)

                guard mapped.isEmpty == false else {
                    completion(.failure(.emptyQuizData))
                    return
                }

                completion(.success(mapped))
            } catch {
                completion(.failure(.decodingFailed))
            }
        }
        .resume()
    }

    private func mapRemoteQuizzes(_ remoteQuizzes: [RemoteQuizDTO]) -> [Quiz] {
        var result: [Quiz] = []

        for remoteQuiz in remoteQuizzes {
            var questions: [Question] = []

            for remoteQuestion in remoteQuiz.questions {
                guard let oneBased = Int(remoteQuestion.answer) else { continue }

                let zeroBased = oneBased - 1
                guard zeroBased >= 0, zeroBased < remoteQuestion.answers.count else { continue }

                let q = Question(
                    text: remoteQuestion.text,
                    answers: remoteQuestion.answers,
                    correctIndex: zeroBased
                )
                questions.append(q)
            }

            guard questions.isEmpty == false else { continue }

            let quiz = Quiz(
                title: remoteQuiz.title,
                description: remoteQuiz.desc,
                iconSystemName: iconName(for: remoteQuiz.title),
                questions: questions
            )

            result.append(quiz)
        }

        return result
    }

    private func iconName(for title: String) -> String {
        let lower = title.lowercased()

        if lower.contains("math") {
            return "function"
        } else if lower.contains("marvel") {
            return "bolt.fill"
        } else if lower.contains("science") {
            return "atom"
        } else if lower.contains("history") {
            return "book.fill"
        } else if lower.contains("sports") {
            return "sportscourt.fill"
        } else {
            return "questionmark.circle"
        }
    }
}
