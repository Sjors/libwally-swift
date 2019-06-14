//
//  AddressTests.swift
//  AddressTests
//
//  Created by Bitcoin Dev on 14/06/2019.
//  Copyright © 2019 Blockchain. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import XCTest
@testable import LibWally

class AddressTests: XCTestCase {
    let hdKey = HDKey("xpub6ASuArnXKPbfEwhqN6e3mwBcDTgzisQN1wXN9BJcM47sSikHjJf3UFHKkNAWbWMiGj7Wf5uMash7SyYq527Hqck2AxYysAA7xmALppuCkwQ")!

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testDeriveLegacyAddress() {
        let address = hdKey.address(.payToPubKeyHash)
        XCTAssertEqual(address.description, "1JQheacLPdM5ySCkrZkV66G2ApAXe1mqLj")
    }
    
    func testDeriveWrappedSegWitAddress() {
        let address = hdKey.address(.payToScriptHashPayToWitnessPubKeyHash)
        XCTAssertEqual(address.description, "3DymAvEWH38HuzHZ3VwLus673bNZnYwNXu")
    }
    
    func testDeriveNativeSegWitAddress() {
        let address = hdKey.address(.payToWitnessPubKeyHash)
        XCTAssertEqual(address.description, "bc1qhm6697d9d2224vfyt8mj4kw03ncec7a7fdafvt")
    }
    
    func testParseLegacyAddress() {
        let address = Address("1JQheacLPdM5ySCkrZkV66G2ApAXe1mqLj")
        XCTAssertNotNil(address)
        XCTAssertEqual(address!.scriptPubKey, ScriptPubKey("76a914bef5a2f9a56a94aab12459f72ad9cf8cf19c7bbe88ac"))
    }
    
    func testParseWrappedSegWitAddress() {
        let address = Address("3DymAvEWH38HuzHZ3VwLus673bNZnYwNXu")
        XCTAssertNotNil(address)
        XCTAssertEqual(address!.scriptPubKey, ScriptPubKey("a91486cc442a97817c245ce90ed0d31d6dbcde3841f987"))
    }
    
    func testParseNativeSegWitAddress() {
        let address = Address("bc1qhm6697d9d2224vfyt8mj4kw03ncec7a7fdafvt")
        XCTAssertNotNil(address)
        XCTAssertEqual(address!.scriptPubKey, ScriptPubKey("0014bef5a2f9a56a94aab12459f72ad9cf8cf19c7bbe"))
    }

}
