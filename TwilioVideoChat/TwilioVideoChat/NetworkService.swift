
final class NetworkService {
    private init() {}

    private static let newLine = "\r\n"

    static func createMultiPart(parameters: [MultipartParameter]) -> (
        [String: String], Data
    ) {
        let uniqueId = UUID().uuidString
        let boundary = "---------------------------\(uniqueId)"

        let boundaryText = "--\(boundary)\(newLine)".data

        let header = [
            "Content-Type": "multipart/form-data; boundary=\(boundary)"
        ]

        var body = Data()

        for parameter in parameters {

            switch parameter.value {
            case .stringType(let string):
                body.append(boundaryText)
                body.append(
                    "Content-Disposition: form-data; name=\"\(parameter.name)\"\(newLine)\(newLine)"
                        .data
                )
                body.append(string.data)
                body.append(newLine.data)

            case .fileType(let contentType, let fileName, let data):

                body.append(boundaryText)
                body.append(
                    "Content-Disposition: form-data; name=\"\(parameter.name)\"; filename=\"\(fileName)\"\(newLine)"
                        .data
                )
                body.append(
                    "Content-Type: \(contentType)\(newLine)\(newLine)".data
                )
                body.append(data)
                body.append(newLine.data)

            }
        }
        body.append("--\(boundary)--\r\n".data)

        return (header, body)

    }

    static func sendURLRequest(
        url: URL,
        method: String,
        headers: [String: String],
        body: Data?,
        errorReference: String? = nil
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
                
                logger.error("\(String(data: data, encoding: .utf8) ?? "Unknown Error in networking.")")
                
                throw NetworkError.badResponse(
                    code: httpResponse.statusCode,
                    errorReference: errorReference
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
