import Foundation

class FoodParsingService: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var lastError: String?

    private let apiClient: APIClient

    init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }

    func parseFood(_ description: String) async -> FoodParsingResponse? {
        isLoading = true
        lastError = nil

        do {
            let response = try await apiClient.parseFoodDescription(description)
            isLoading = false
            return response
        } catch {
            isLoading = false
            if let apiError = error as? APIError {
                lastError = apiError.localizedDescription
            } else {
                lastError = error.localizedDescription
            }
            return nil
        }
    }
}
