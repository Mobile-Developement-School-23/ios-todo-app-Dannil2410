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
        return try await withCheckedThrowingContinuation { continuation in
            URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
                if let error = error {
                    print("error")
                    continuation.resume(throwing: error)
                } else if httpStatusCodeSuccess.contains((response as? HTTPURLResponse)?.statusCode ?? 0)
                            || data == nil {
                    print("response")
                    continuation.resume(throwing: URLError(.badServerResponse))
                } else if let data = data,
                          let response = response {
                    print("data")
                    continuation.resume(returning: (data, response))
                }
            }
        }
    }

//    private func dataTask(for urlRequest: URLRequest) async throws -> (Data, URLResponse) {
//        let httpStatusCodeSuccess = 200..<300
//        return try await withTaskCancellationHandler(operation: {
//            try await withCheckedThrowingContinuation { continuation in
//                URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
//                    if let error = error {
//                        continuation.resume(throwing: error)
//                    } else if httpStatusCodeSuccess.contains((response as? HTTPURLResponse)?.statusCode ?? 0)
//                                || data == nil {
//                        continuation.resume(throwing: URLError(.badServerResponse))
//                    } else if let data = data,
//                              let response = response {
//                        continuation.resume(returning: (data, response))
//                    }
//                }
//            }
//        }, onCancel: <#T##() -> Void#>)
//    }
}
