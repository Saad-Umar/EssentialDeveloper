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

    func test_init_doesNotRequestDataFromURL() {
        let (_,client) = makeSUT()
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "www.my-url.com")!
        let (sut,client) = makeSUT(url: url)
        sut.load {_ in}
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "www.my-url.com")!
        let (sut,client) = makeSUT(url: url)
        sut.load {_ in}
        sut.load {_ in}
        XCTAssertEqual(client.requestedURLs, [url,url])
    }

    func test_load_deliversErrorOnClientError() {
        let (sut,client) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(.connectivity)) {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)

        }
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut,client) = makeSUT()
        
        
        let samples = [199,201,300,400,500]
        
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: .failure(.invalidData)) {
                client.complete(withStatusCode: code, at: index)
            }
        }
        
    }
   
    func test_load_deliversErrorOnResponse200HTTPResponseWithInvalidJSON() {
        let (sut,client) = makeSUT()
        
        
        expect(sut, toCompleteWith: .failure(.invalidData)) {
            let invalidJSON = Data(bytes: "Invalid JSON".utf8)
            client.complete(withStatusCode: 200, data:invalidJSON)
        }
        
    }
    
    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() {
        let (sut,client) = makeSUT()
        
        expect(sut, toCompleteWith: .success([])) {
            let emptyListJSON = Data(bytes: "{\"items\": []}".utf8)
            
            client.complete(withStatusCode: 200, data: emptyListJSON)
        }
        
    }
    
    func test_load_deliversItemsOn200HTTPResponseWithJSONItems() {
        let (sut, client) = makeSUT()
        
        let item1 = FeedItem()
    }
    
}


extension RemoteFeedLoaderTests {
    //MARK: - SPY
    
    private class HTTPClientSpy: HTTPClient {
        private var messages = [(url:URL,completion:(HTTPClientResult)->Void)]()
        var requestedURLs: [URL] {
            messages.map { $0.url }
    }
        
        func get(from url: URL, completion: @escaping (HTTPClientResult)->Void) {
            self.messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, data: Data = Data(), at index: Int = 0) {
            let response = HTTPURLResponse(url: requestedURLs[index],
                                          statusCode: code,
                                          httpVersion: nil,
                                          headerFields: nil)!
            
            messages[index].completion(.success(response, data))
        }
    }
    //MARK: - Helpers
    
    private func makeSUT(url:URL = URL(string: "www.my-url-2.com")!) -> (RemoteFeedLoader,HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    private func expect(_ sut: RemoteFeedLoader, toCompleteWith result: RemoteFeedLoader.Result, action: ()->Void, file: StaticString = #file, line: UInt = #line) {
        
        var capturedResults = [RemoteFeedLoader.Result]()
        
        sut.load { capturedResults.append($0) }
      
        action()
        
        XCTAssertEqual(capturedResults,[result], file: file, line:line)

        
    }
}


