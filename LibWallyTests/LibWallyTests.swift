//
//  LibWallyTests.swift
//  LibWallyTests
//
//  Created by Sjors on 27/05/2019.
//  Copyright © 2019 Blockchain. All rights reserved.
//

import XCTest
@testable import LibWally

class LibWallyTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testGetBIP39WordList() {
        // Check length
        XCTAssertEqual(BIP39WordList.count, 2048)
        
        // Check first word
        XCTAssertEqual(BIP39WordList.first, "abandon")
    }

}
