
import Foundation

enum NetworkError: Error, LocalizedError {
    case failToCreateURL
    case badResponse(code: Int, errorReference: String?)
    case dataTaskError(Error)

    var errorDescription: String? {
        switch self {
        case .failToCreateURL:
            "Fail to create URL."
        case .badResponse(let code, errorReference: _):
            "Network failed. Code:\(code)."
        case .dataTaskError(let error):
            "Error making network request: \(error.localizedDescription)"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .badResponse(code: _, errorReference: let reference):
            if let reference {
                "Error Code Reference: \(reference)."
            } else {
                "Please check your network."
            }
        default:
            nil
        }
    }
}
