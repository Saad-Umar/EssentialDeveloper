//
//  RemoteFeedLoaderTests.swift
//  ProperDependencyInjectionTests
//
//  Created by Tixsee on 5/27/23.
//

import Foundation
import XCTest
import ProperDependencyInjection

final class RemoteFeedLoaderTests: XCTestCase {
    private class HTTPClientSpy: HTTPClient {
        var requestedURLs = [URL]()
        var error: Error?
        
        func get(from url: URL, completion: @escaping (Error)->Void) {
            if let error = error {
                completion(error)
            }
            self.requestedURLs.append(url)
        }
    }

    func test_init_doesNotRequestDataFromURL() {
        let (_,client) = makeSUT()
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "www.my-url.com")!
        let (sut,client) = makeSUT(url: url)
        sut.load()
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "www.my-url.com")!
        let (sut,client) = makeSUT(url: url)
        sut.load()
        sut.load()
        XCTAssertEqual(client.requestedURLs, [url,url])
    }

    func test_load_deliversErrorOnClientError() {
        let (sut,client) = makeSUT()
        var capturedError: RemoteFeedLoader.Error?
        client.error = NSError(domain: "Test", code: 0)
        
        sut.load { error in
            capturedError = error
        }
        
        XCTAssertEqual(capturedError,.connectivity)
    }
    //MARK: - Helpers
    
    private func makeSUT(url:URL = URL(string: "www.my-url-2.com")!) -> (RemoteFeedLoader,HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
}


