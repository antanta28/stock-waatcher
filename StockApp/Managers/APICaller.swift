//
//  APICaller.swift
//  StockApp
//
//  Created by Kirill Fedin on 08.01.2022.
//

import Foundation

final class APICaller {
    static let shared = APICaller()
    private init() {}
    
    private struct C {
        static let apiKey = "c1b5vq748v6rcdq9uaq0"
        static let sandBoxApiKey = "sandbox_c1b5vq748v6rcdq9uaqg"
        static let baseUrl = "https://finnhub.io/api/v1/"
    }
    
    // MARK: - Public
    public func marketData(
        for symbol: String,
        numberOfDays: Int = 7,
        completion: @escaping (Result<MarketDataResponse, Error>) -> Void
    ) {
        let today = Date()
        let prior = today.addingTimeInterval(TimeInterval(-numberOfDays * 3600 * 24))
        
        let url = url(
            for: .marketData,
               queryParams: [
                "symbol": symbol,
                "resolution": "1",
                "from": "\(Int(prior.timeIntervalSince1970))",
                "to": "\(Int(today.timeIntervalSince1970))"
               ]
        )
        
        request(
            url: url,
            expecting: MarketDataResponse.self,
            completion: completion
        )
    }
    
    
    public func search(
        query: String,
        completion: @escaping (Result<SearchResponse, Error>) -> Void
    ) {
        guard let safeQuery = query.addingPercentEncoding(
            withAllowedCharacters: .urlQueryAllowed
        ) else {
            return
        }
        request(
            url: url(
                for: .search,
                   queryParams: ["q": safeQuery]
            ),
            expecting: SearchResponse.self,
            completion: completion
        )
    }
    
    public func news(
        for type: NewsViewController.`Type`,
        completion: @escaping (Result<[NewsStory], Error>) -> Void
    ) {
        let url: URL?
        
        switch type {
        case .topStories:
            url = self.url(for: .topStories, queryParams: ["category": "general"])
        case .company(let symbol):
            let today = Date()
            let weekAgo = today.addingTimeInterval(-(3600 * 24 * 7))
            
            url = self.url(
                for: .companyNews,
                   queryParams: [
                    "symbol": symbol,
                    "from": DateFormatter.newsDateFormatter.string(from: weekAgo),
                    "to": DateFormatter.newsDateFormatter.string(from: today)
                   ]
            )
        }
        
        request(
            url: url,
            expecting: [NewsStory].self,
            completion: completion
        )
    }
    
    public func financialMetrics(
        for symbol: String,
        completion: @escaping (Result<FinancialMetricsResponse, Error>) -> Void
    ) {
        let url = url(
            for: .financials,
               queryParams: [
                "symbol": symbol,
                "metric": "all"
               ]
        )
        
        request(
            url: url,
            expecting: FinancialMetricsResponse.self,
            completion: completion
        )
    }
    
    // MARK: - Private
    private enum EndPoint: String {
        case search
        case topStories = "news"
        case companyNews = "company-news"
        case marketData = "stock/candle"
        case financials = "stock/metric"
    }
    
    private enum APIError: Error {
        case invalidURL
        case noDataReturned
    }
    
    private func url(
        for endPoint: EndPoint,
        queryParams: [String: String] = [:]
    ) -> URL? {
        var urlString = C.baseUrl + endPoint.rawValue
        
        var queryItems = [URLQueryItem]()
        for (name, value) in queryParams {
            queryItems.append(.init(name: name, value: value))
        }
        // Add token
        queryItems.append(.init(name: "token", value: C.apiKey))
        
        // convert query item to suffix stream
        urlString += "?" + queryItems.map { "\($0.name)=\($0.value ?? "")" }.joined(separator: "&")
        
        print(urlString)
        return URL(string: urlString)
    }
    
    /// Generic Request Function
    private func request<T: Codable>(
        url: URL?,
        expecting: T.Type,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        guard let url = url else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard error == nil, let data = data else {
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.failure(APIError.noDataReturned))
                }
                
                return
            }
            
            
            do {
                let result = try JSONDecoder().decode(expecting, from: data)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}
