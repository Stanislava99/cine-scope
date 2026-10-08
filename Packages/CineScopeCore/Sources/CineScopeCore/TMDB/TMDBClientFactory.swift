import Foundation

public enum TMDBClientFactory {
    public static func make(configuration: AppConfiguration, httpClient: any HTTPClient = URLSessionHTTPClient()) -> any TMDBClient {
        if configuration.usesLiveAPI {
            return LiveTMDBClient(httpClient: httpClient, configuration: configuration)
        }
        return FixtureTMDBClient()
    }
}
