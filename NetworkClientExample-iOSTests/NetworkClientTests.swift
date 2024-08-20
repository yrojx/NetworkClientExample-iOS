//
//  NetworkClientTests.swift
//  NetworkClientExample-iOSTests
//
//  Created by Yossan Rahmadi on 21/08/24.
//

import XCTest

final class NetworkClientTests: XCTestCase {
    private var mockCache: MockURLCache!
    private var networkClient: NetworkClient!
    
    override func setUp() {
        super.setUp()
        
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        mockCache = MockURLCache()
        config.urlCache = mockCache
        
        networkClient = NetworkClient(urlSessionConfiguration: config)
    }
    
    override func tearDown() {
        mockCache = nil
        networkClient = nil
        super.tearDown()
    }
    
    func test_request_success() async throws {
        // Given
        let expectedData = "{\"key\":\"value\"}".data(using: .utf8)
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: request.allHTTPHeaderFields)
            
            return (expectedData!, response!)
        }
        
        // When
        let result: MockDecodable = try await networkClient.request(target: MockValidEndpoint())
        
        // Then
        XCTAssertEqual(result.key, "value")
    }
    
    func test_request_usesCache() async throws {
        // Given
        let expectedData = "{\"key\":\"cachedValue\"}".data(using: .utf8)
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: request.allHTTPHeaderFields)
            
            return (expectedData!, response!)
        }
        
        // When
        let result: MockDecodable = try await networkClient.request(target: MockValidEndpoint())
        
        // Then
        XCTAssertEqual(result.key, "cachedValue")
        XCTAssertEqual(self.mockCache.storedResponses.count, 1)
        XCTAssertFalse(mockCache.isCacheUsed)
        
        // Cache should be used for this request
        let cachedResult: MockDecodable = try await networkClient.request(target: MockValidEndpoint())
        
        XCTAssertEqual(cachedResult.key, "cachedValue")
        XCTAssertTrue(mockCache.isCacheUsed)
    }
    
    func test_request_retriesThenSuccess() async throws {
        // Given
        let expectedData = "{\"key\":\"value\"}".data(using: .utf8)
        let target = MockValidEndpoint()
        
        // Simulate retries
        var attemptCount = 0
        MockURLProtocol.requestHandler = { request in
            attemptCount += 1
            if attemptCount < target.retries {
                throw URLError(.timedOut) // Simulate network timeout
            }
            
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: request.allHTTPHeaderFields)
            return (expectedData!, response!) // Return actual data on the final attempt
        }
        
        // When
        let result: MockDecodable = try await networkClient.request(target: target)
        
        // Then
        XCTAssertEqual(result.key, "value")
        XCTAssertEqual(attemptCount, 3)
    }
    
    func test_request_requestFailed() async throws {
        // Given
        let expectedError = NSError(domain: "", code: 0)
        MockURLProtocol.requestHandler = { _ in
            throw expectedError
        }
        
        do {
            // When
            let _: MockDecodable = try await networkClient.request(target: MockValidEndpoint())
            XCTFail("Error was not thrown")
        } catch {
            // Then
            XCTAssertEqual(error as? NetworkError, NetworkError.requestFailed(expectedError))
        }
    }
    
    func test_request_badUrl() async throws {
        do {
            // When
            let _: MockDecodable = try await networkClient.request(target: MockBadURLEndpoint())
            XCTFail("Error was not thrown")
        } catch {
            // Then
            XCTAssertEqual(error as? NetworkError, NetworkError.badURL)
        }
    }
    
    func test_request_invalidResponse() async throws {
        // Given
        let expectedData = "{\"key\":\"value\"}".data(using: .utf8)
        
        MockURLProtocol.requestHandler = { request in
            let response = URLResponse()
            
            return (expectedData!, response)
        }
        
        do {
            // When
            let _: MockDecodable = try await networkClient.request(target: MockValidEndpoint())
            XCTFail("Error was not thrown")
        } catch {
            // Then
            XCTAssertEqual(error as? NetworkError, NetworkError.invalidResponse)
        }
    }
    
    func test_request_unsupportedContentType() async throws {
        // Given
        let expectedData = "{\"key\":\"value\"}".data(using: .utf8)
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: request.allHTTPHeaderFields)
            
            return (expectedData!, response!)
        }
        
        do {
            // When
            let _: MockDecodable = try await networkClient.request(target: MockUnsupportedContentTypeEndpoint())
            XCTFail("Error was not thrown")
        } catch {
            // Then
            XCTAssertEqual(error as? NetworkError, NetworkError.unsupportedContentType)
        }
    }
    
    func test_request_notFound() async throws {
        // Given
        let expectedData = "{\"key\":\"value\"}".data(using: .utf8)
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 404, httpVersion: nil, headerFields: request.allHTTPHeaderFields)
            
            return (expectedData!, response!)
        }
        
        do {
            // When
            let _: MockDecodable = try await networkClient.request(target: MockValidEndpoint())
            XCTFail("Error was not thrown")
        } catch {
            // Then
            XCTAssertEqual(error as? NetworkError, NetworkError.notFound)
        }
    }
    
    func test_request_internalServerError() async throws {
        // Given
        let expectedData = "{\"key\":\"value\"}".data(using: .utf8)
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 500, httpVersion: nil, headerFields: request.allHTTPHeaderFields)
            
            return (expectedData!, response!)
        }
        
        do {
            // When
            let _: MockDecodable = try await networkClient.request(target: MockValidEndpoint())
            XCTFail("Error was not thrown")
        } catch {
            // Then
            XCTAssertEqual(error as? NetworkError, NetworkError.internalServerError)
        }
    }
    
    func test_request_unknownError() async throws {
        // Given
        let expectedData = "{\"key\":\"value\"}".data(using: .utf8)
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 6, httpVersion: nil, headerFields: request.allHTTPHeaderFields)
            
            return (expectedData!, response!)
        }
        
        do {
            // When
            let _: MockDecodable = try await networkClient.request(target: MockValidEndpoint())
            XCTFail("Error was not thrown")
        } catch {
            // Then
            XCTAssertEqual(error as? NetworkError, NetworkError.unknownError(statusCode: 6))
        }
    }
    
    func test_request_decodingFailed() async throws {
        // Given
        let expectedData = "{\"key\";\"value\"}".data(using: .utf8)
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: request.allHTTPHeaderFields)
            
            return (expectedData!, response!)
        }
        
        do {
            // When
            let _: MockDecodable = try await networkClient.request(target: MockValidEndpoint())
            XCTFail("Error was not thrown")
        } catch let error as NetworkError {
            // Then
            switch error {
            case .decodingFailed(let decodingError):
                XCTAssertEqual(error, NetworkError.decodingFailed(decodingError))
            default:
                XCTFail("Error was not expected")
            }
        }
    }
    
    func test_NetworkError_defaultEquatable() async throws {
        XCTAssertNotEqual(NetworkError.badURL, NetworkError.invalidResponse)
    }
}
