//
//  SeatGeekTests.swift
//  SeatGeekTests
//
//  Created by Vici Shaweddy on 3/2/21.
//

import XCTest
@testable import SeatGeek

class URLSessionDataTaskMock: URLSessionDataTask {
    private let closure: () -> Void

    init(closure: @escaping () -> Void) {
        self.closure = closure
    }

    override func resume() {
        closure()
    }
}

class URLSessionMock: URLSession {
    typealias CompletionHandler = (Data?, URLResponse?, Error?) -> Void

    var data: Data?
    var error: Error?
    
    override func dataTask(
        with request: URLRequest,
        completionHandler: @escaping CompletionHandler)
    -> URLSessionDataTask {
        let data = self.data
        let error = self.error

        return URLSessionDataTaskMock {
            completionHandler(data, nil, error)
        }
    }
}

class EventControllerTests: XCTestCase {
    private var session: URLSessionMock!
    private var controller: EventController!
    
    override func setUp() {
        super.setUp()
        self.session = URLSessionMock()
        self.controller = EventController(session: session)
    }
    
    func testFetchEventsFromServer() throws {
        session.data = try genMockResponse()
        let expectation = self.expectation(description: "proper response and parsing")
        controller.fetchEventsFromServer { result in
            switch result {
            case .success(let events):
                XCTAssertFalse(events.isEmpty)
                expectation.fulfill()
            case .failure:
                XCTFail()
            }
        }
        
        _ = XCTWaiter.wait(for: [expectation], timeout: 0.1)
    }
    
    func testSearchEvents() throws {
        session.data = try genMockResponse()
        let expectation = self.expectation(description: "proper response and parsing")
        
        controller.search(with: "test") { result in
            switch result {
            case .success(let events):
                XCTAssertFalse(events.isEmpty)
                expectation.fulfill()
            case .failure:
                XCTFail()
            }
        }
        
        _ = XCTWaiter.wait(for: [expectation], timeout: 0.1)
    }
    
    private func genMockResponse() throws -> Data {
        let event = EventRepresentation(date: Date(), title: "Test", performers: [], venue: .init(city: "new york", state: "NY"), id: 0)
        let mockResponse = EventsResponse(events: [event])
        
        let encoder = JSONEncoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        encoder.dateEncodingStrategy = .formatted(dateFormatter)

        return try encoder.encode(mockResponse)
    }
}
