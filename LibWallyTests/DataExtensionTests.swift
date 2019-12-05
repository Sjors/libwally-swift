//
//  DataExtensionTests.swift
//  DataExtensionTests 
//
//  Created by Sjors Provoost on 05/12/2019.
//  Copyright © 2019 Sjors Provoost. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import XCTest

class DataExtensionTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testHexString() {
        let hexString = "01234567890abcde"
        let data = Data(hexString)
        XCTAssertEqual(data?.hexString, hexString)
    }
}
