//
//  URLSessionExtension.swift
//  ToDoList
//
//  Created by Даниил Кизельштейн on 05.07.2023.
//

import Foundation

extension URLSession {
    func dataTask(for urlRequest: URLRequest) async throws -> (Data, URLResponse) {
        let httpStatusCodeSuccess = 200..<300

        var task: URLSessionDataTask?

        return try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                task = self.dataTask(with: urlRequest) { (data, response, error) in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else if !httpStatusCodeSuccess.contains((response as? HTTPURLResponse)?.statusCode ?? 0)
                                || data == nil {
                        continuation.resume(throwing: URLError(.badServerResponse))
                    } else if let data = data,
                              let response = response {
                        continuation.resume(returning: (data, response))
                    }
                }
                task?.resume()
            }
        } onCancel: { [weak task] in
            task?.cancel()
        }
    }
}
