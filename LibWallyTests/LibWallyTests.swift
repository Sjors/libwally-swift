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
        // Get list
        let list = BIP39WordList.all
        
        // Check length
        XCTAssertEqual(list.count, 2048)
        
        // Check first word
        XCTAssertEqual(list.first, "abandon")
    }

}
