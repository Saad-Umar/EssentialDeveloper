//
//  RemoteFeedLoaderTests.swift
//  ProperDependencyInjectionTests
//
//  Created by Tixsee on 5/27/23.
//

import Foundation
import XCTest

class RemoteFeedLoader {
    let client: HTTPClient
    let url: URL
    
    init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    func load() {
        client.get(from: url)
    }
}

protocol HTTPClient {
    func get(from url: URL)
}

final class RemoteFeedLoaderTests: XCTestCase {
    private class HTTPClientSpy: HTTPClient {
        var requestedURL: URL?
        
        func get(from url: URL) {
            self.requestedURL = url
        }
    }

    func test_init_noUrl() {
        let (_,client) = makeSUT()
        XCTAssertNil(client.requestedURL)
    }
    
    func test_init_withUrl() {
        let url = URL(string: "www.my-url.com")!
        let (sut,client) = makeSUT(url: url)
        sut.load()
        XCTAssertEqual(client.requestedURL, url)
    }

    //MARK: - Helpers
    
    private func makeSUT(url:URL = URL(string: "www.my-url-2.com")!) -> (RemoteFeedLoader,HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
}
