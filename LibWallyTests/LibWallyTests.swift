//
//  LibWallyTests.swift
//  LibWallyTests
//
//  Created by Sjors on 27/05/2019.
//  Copyright © 2019 Blockchain. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md.
//

import XCTest
@testable import LibWally

class LibWallyTests: XCTestCase {
    let validMnemonic = ["abandon", "abandon", "abandon", "abandon", "abandon", "abandon", "abandon", "abandon", "abandon", "abandon", "abandon", "about"]

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testGetBIP39WordList() {
        // Check length
        XCTAssertEqual(BIP39Words.count, 2048)
        
        // Check first word
        XCTAssertEqual(BIP39Words.first, "abandon")
    }
    
    func testMnemonicIsValid() {
        XCTAssertTrue(BIP39Mnemonic.isValid(validMnemonic))
        XCTAssertFalse(BIP39Mnemonic.isValid(["notavalidword"]))
        XCTAssertFalse(BIP39Mnemonic.isValid(["abandon"]))
    }
    
    func testInitializeMnemonic() {
        let mnemonic = BIP39Mnemonic(validMnemonic)
        XCTAssertNotNil(mnemonic)
        if (mnemonic != nil) {
            XCTAssertEqual(mnemonic!.words, validMnemonic)
        }
    }
    
    func testInitializeInvalidMnemonic() {
        let mnemonic = BIP39Mnemonic(["notavalidword"])
        XCTAssertNil(mnemonic)
    }

}
