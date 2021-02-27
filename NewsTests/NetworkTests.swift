//
//  NetworkTests.swift
//  NewsTests
//
//  Created by Nikolai Ivanov on 09.02.2021.
//

import XCTest
@testable import News

class NetworkTests: XCTestCase {
    var network: Network!
    
    override func setUp() {
        super.setUp()
        network = Network()
    }
    
    override func tearDown() {
        network = nil
        super.tearDown()
    }
    
    func testLoadNews() {
        let networkExpectation = expectation(description: "News loaded")
        
        network.loadNewsData(searchingText: nil, country: "us", category: "general") { result in
            print(result)
            switch result {
            case .success:
                networkExpectation.fulfill()
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        }
        waitForExpectations(timeout: 10)
    }
    
    func testImageDownloading() {
        let loadImageExpectation = expectation(description: "Image loaded")
        let size = CGSize(width: 400, height: 300)
        
        network.loadImage(imageUrl: "https://upload.wikimedia.org/wikipedia/en/9/95/Test_image.jpg") { image in
            XCTAssertEqual(image.size, size)
            loadImageExpectation.fulfill()
        }
        waitForExpectations(timeout: 10)
    }
}
