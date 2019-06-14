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

}
