import Foundation

nonisolated(unsafe) let defaultAPIClient = APIClient()

class APIClient: @unchecked Sendable {
    static let shared: APIClient = defaultAPIClient

    private let baseURL: URL
    private let session: URLSession

    init(baseURL: URL = URL(string: "http://localhost:8000")!, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }

    func parseFoodDescription(_ description: String) async throws -> FoodParsingResponse {
        let endpoint = baseURL.appendingPathComponent("/api/parse-food")

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload: [String: String] = ["description": description]
        request.httpBody = try JSONEncoder().encode(payload)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard 200..<300 ~= httpResponse.statusCode else {
            throw APIError.httpError(statusCode: httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        let decodedResponse = try decoder.decode(FoodParsingResponse.self, from: data)

        return decodedResponse
    }
}

enum APIError: LocalizedError {
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let statusCode):
            return "HTTP Error: \(statusCode)"
        case .decodingError:
            return "Failed to decode response"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}
