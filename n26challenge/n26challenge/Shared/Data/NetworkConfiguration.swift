import Foundation

struct NetworkConfiguration {
    let host: String
    let jsonDecoder: JSONDecoder

    init(
        host: String,
        jsonDecoder: JSONDecoder = JSONDecoder()
    ) {
        self.host = host
        self.jsonDecoder = jsonDecoder
    }
}
