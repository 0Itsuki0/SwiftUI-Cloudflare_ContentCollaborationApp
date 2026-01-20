//
//  NetworkService.swift
//  TwilioVideoChat
//
//  Created by Itsuki on 2026/01/19.
//

import SwiftUI

final class NetworkService {
    private init() {}

    static func sendURLRequest(
        url: URL,
        method: String,
        headers: [String: String],
        body: Data?,
    ) async throws -> Data {
        var request = URLRequest(url: url)

        request.httpMethod = method

        request.allHTTPHeaderFields = headers
        request.httpBody = body

        do {
            let (data, response) = try await URLSession.shared.data(
                for: request
            )
            let httpResponse = response as? HTTPURLResponse
            if let httpResponse, !httpResponse.isSuccess {

                print(
                    "\(String(data: data, encoding: .utf8) ?? "Unknown Error in networking.")"
                )

                throw NetworkError.badResponse(
                    code: httpResponse.statusCode
                )
            }
            return data
        } catch (let error) {
            throw NetworkError.dataTaskError(error)
        }

    }

    static func decode<T>(_ type: T.Type, from data: Data) throws -> T
    where T: Decodable {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        do {
            let decodedResponse = try decoder.decode(T.self, from: data)
            return decodedResponse
        } catch (let error) {
            throw error
        }
    }

    static func decode<T>(_ type: T.Type, from string: String) throws -> T
    where T: Decodable {
        let data = Data(string.utf8)
        return try self.decode(type, from: data)
    }
}
