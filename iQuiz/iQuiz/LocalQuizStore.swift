//
//  LocalQuizStore.swift
//  iQuiz
//
//  Created by Hrudhai Umas on 2/24/26.
//

import Foundation

final class LocalQuizStore
{

    static let shared = LocalQuizStore()
    private init() {}

    private let fileName = "quizzes_cache.json"

    private var fileURL: URL?
    {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?
            .appendingPathComponent(fileName)
    }

    func save(quizzes: [Quiz])
    {
        guard let url = fileURL else { return }

        do
        {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted]
            let data = try encoder.encode(quizzes)
            try data.write(to: url, options: .atomic)
        } catch
        {
            print("Failed to save quizzes locally: \(error)")
        }
    }

    func load() -> [Quiz]?
    {
        guard let url = fileURL else { return nil }

        do {
            let data = try Data(contentsOf: url)
            let quizzes = try JSONDecoder().decode([Quiz].self, from: data)
            return quizzes.isEmpty ? nil : quizzes
        } catch
        {
            print("Failed to load local quizzes: \(error)")
            return nil
        }
    }

    func hasCachedQuizzes() -> Bool
    {
        guard let url = fileURL else { return false }
        return FileManager.default.fileExists(atPath: url.path)
    }
}
